global _start 
section .data
  pipe db "|"
  dash db "-"
  newline db 0xA
  space db "."
  snake_head db "@"
  clear_screen db 27, "[2J", 27, "[H" ; ANSI escape sequence to clear screen and set cursor
  clear_len equ $ - clear_screen
  
  time:
    dq 0              ; tv_sec
    dq 100000000      ; tv_nsec (100ms = 0.1s)

  ; constants for fcntl
  F_GETFL equ 3
  F_SETFL equ 4
  O_NONBLOCK equ 2048

section .bss
  input_buffer resb 8  ; buffer for input
  flags resq 1         ; for storing file flags
  
section .text
_start:
  ; set stdin to non-blocking mode
  mov rax, 72         ; fcntl syscall
  mov rdi, 0          ; stdin file descriptor
  mov rsi, F_GETFL    ; get current flags
  syscall
  
  mov [flags], rax    ; save current flags
  or rax, O_NONBLOCK  ; add non-blocking flag
  
  mov rdi, 0          ; stdin file descriptor
  mov rsi, F_SETFL    ; set flags
  mov rdx, rax        ; new flags value
  mov rax, 72         ; fcntl syscall
  syscall

  ; initialize snake position
  mov r8, 0x08        ; snake Y position (row)
  mov r9, 0x0F        ; snake X position (column)
  
  ; initialize direction (0=none, 1=up, 2=down, 3=left, 4=right)
  mov r12, 1

game_loop:
  ; clear the screen
  mov rax, 1
  mov rdi, 1
  mov rsi, clear_screen
  mov rdx, clear_len
  syscall

  ; check for input (non-blocking)
  mov rax, 0
  mov rdi, 0
  mov rsi, input_buffer
  mov rdx, 1
  syscall

  ; process input if available
  test rax, rax       ; check if any bytes were read
  jz update_position
  
  ; process input
  mov al, byte [input_buffer]
  cmp al, 'w'
  je set_up
  cmp al, 's'
  je set_down
  cmp al, 'a'
  je set_right
  cmp al, 'd'
  je set_left
  cmp al, 'q'
  je exit_program
  jmp update_position

set_up:
  mov r12, 1
  jmp update_position

set_down:
  mov r12, 2
  jmp update_position

set_right:
  mov r12, 4
  jmp update_position

set_left:
  mov r12, 3
  jmp update_position

update_position:
  ; update position based on current direction
  cmp r12, 0
  je draw_game        ; no movement if no direction
  cmp r12, 1
  je move_up
  cmp r12, 2
  je move_down
  cmp r12, 3
  je move_left
  cmp r12, 4
  je move_right
  jmp draw_game

move_up:
  dec r8              ; move snake up (decrease Y)
  ; wrap around if at top edge
  cmp r8, 0
  jge draw_game
  mov r8, 0x15
  jmp draw_game

move_down:
  inc r8              ; move snake down (increase Y)
  ; wrap around if at bottom edge
  cmp r8, 0x16
  jl draw_game
  xor r8, r8
  jmp draw_game

move_left:
  dec r9              ; move snake left (decrease X)
  ; wrap around if at left edge
  cmp r9, 0
  jge draw_game
  mov r9, 0x1D
  jmp draw_game

move_right:
  inc r9              ; move snake right (increase X)
  ; wrap around if at right edge
  cmp r9, 0x1E
  jl draw_game
  xor r9, r9
  jmp draw_game

draw_game:
  ; draw top border
  xor r13, r13
  xor r14, r14
  mov rax, 1
  mov rdi, 1
  mov rdx, 1
  lea rsi, [dash]

roof_loop:
  syscall
  inc r14
  cmp r14, 0x20
  jne roof_loop
  
  lea rsi, [newline]
  syscall

  ; draw walls and snake
wall_loop:
  lea rsi, [pipe]
  syscall
  
  ; check if this is the snake's row
  cmp r13, r8
  je snake_row
  
  ; not snake row, just draw spaces
  lea rsi, [space]
  mov r15, 0x1e
space_loop:
  syscall
  dec r15
  test r15, r15
  jnz space_loop
  jmp end_row

snake_row:
  lea rsi, [space]
  mov r15, 0x1e
snake_space_loop:
  cmp r15, r9
  je print_snake
  syscall
  dec r15
  test r15, r15
  jnz snake_space_loop
  jmp end_row
    
print_snake:
  lea rsi, [snake_head]
  syscall
  dec r15
  lea rsi, [space]
  test r15, r15
  jz end_row
    
remaining_spaces:
  syscall
  dec r15
  test r15, r15
  jnz remaining_spaces

end_row:
  lea rsi, [pipe]
  syscall
  lea rsi, [newline]
  syscall
  inc r13
  cmp r13, 0x16
  jne wall_loop
      
  ; draw bottom border
  mov r10, 0x20
  lea rsi, [dash]
floor_loop:
  syscall
  dec r10
  test r10, r10
  jnz floor_loop
    
  lea rsi, [newline]
  syscall

  ; sleep
  mov rax, 35
  lea rdi, [time]
  xor rsi, rsi
  syscall
  
  jmp game_loop
    
exit_program:
  ; restore original stdin flags before exiting
  mov rax, 72         ; fcntl syscall
  mov rdi, 0          ; stdin file descriptor
  mov rsi, F_SETFL    ; set flags
  mov rdx, [flags]    ; original flags
  syscall

  ; exit program
  mov rax, 60
  xor rdi, rdi
  syscall
