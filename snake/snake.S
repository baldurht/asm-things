global _start 
section .data
  pipe: db "|"
  dash: db "-"
  newline: db 0xA
  space: db "."
  snake_head: db "#"
  clear_screen: db 27, "[2J", 27, "[H" ; ANSI escape sequence to clear screen and set cursor
  clear_len equ $ - clear_screen
  
section .bss

; TODO sikkert gjøre loopsa til functions
; TODO gjøre koden mer lett lest?
; TODO finne ut hvordan jeg kan time loopsene.
;      liksom ha x antal loops i sekundet 
;       ^^^^^^^^  
;       fant ut av det over, jeg tror jeg kan bruke syscall 35 nanosleep

section .text
_start:

; TODO r13 = y r15 = x
; TODO r8 = x r9 = y
; TODO want to save the cords in one register
mov r8, 0x08
mov r9, 0x16

game_loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, clear_screen
  mov rdx, clear_len
  syscall

  mov r14, 0x20
  mov rax, 1
  mov rdi, 1
  mov rdx, 1
  lea rsi, [dash]
  roof_loop:
    syscall
    dec r14
    test r14, r14
    jnz roof_loop

  lea rsi, [newline]
  syscall

  mov r13, 0x16
  wall_loop:
    lea rsi, [pipe]
    syscall

    cmp r13, r8
    je snake_row

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

      dec r13
      test r13, r13
      jnz wall_loop
      
      mov r10, 0x20
      lea rsi, [dash]

  floor_loop:
    syscall
    dec r10
    test r10, r10
    jnz floor_loop
    
    lea rsi, [newline]
    syscall
  inc r8

  jmp game_loop
    
; exit program
mov rax, 60
xor rdi, rdi
syscall
