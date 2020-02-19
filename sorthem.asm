%include "asm_io.inc"

SECTION .data

arr1: dd 0,0,0,0,0,0,0,0,0
msg1: db " ",0
msg2: db "o",0
msg3: db "|",0
msgn: db "XXXXXXXXXXXXXXXXXXXXXXX",10,0
stat1: db "initial configuration",10,0
stat2: db "final configuration",10,0
err1: db "incorrect number of command line arguments",10,0
err2: db "incorrect command line argument",10,0

SECTION .bss
   N: resd 1
   M: resd 1
   O: resd 1
   P: resd 1
   Q: resd 1
   var1: resd 1
   var2: resd 2

SECTION .text
   global  asm_main

showp:
   enter 0,0
   pusha


   mov ebx, [ebp+8]
   mov ecx, [ebp+12]
   mov [Q], ecx
   dec ecx
   mov eax, dword 4
   mul ecx
   add ebx, eax
   mov esi, dword 0
   while:
      inc esi
      cmp esi, [Q]
      ja end_while
      cmp dword [ebx], dword 0
      je fff1

      mov edx, dword 11
      sub edx, dword [ebx]
      mov [M], edx
      mov edx, [M]
      LOOP1:
        mov eax, msg1
        call print_string
        dec edx
        cmp edx, dword 0
        jne LOOP1

      mov edx, dword [ebx]
      LOOP2:
        mov eax, msg2
        call print_string
        dec edx
        cmp edx, dword 0
        jne LOOP2

      mov eax, msg3
      call print_string

      mov edx, dword [ebx]
      LOOP3:
        mov eax, msg2
        call print_string
        dec edx
        cmp edx, dword 0
        jne LOOP3

      mov edx, [M]
      LOOP4:
        mov eax, msg1
        call print_string
        dec edx
        cmp edx, dword 0
        jne LOOP4

      fff:
        call print_nl
        sub ebx, 4
        jmp while

      fff1:
        sub ebx, 4
        jmp while

   end_while:
      mov eax, msgn
      call print_string
      call read_char
      popa
      leave
      ret


sorthem:
  enter 0,0

   mov ecx, [ebp+12]
   mov ebx, [ebp+8]
   cmp ecx, dword 1
   je return
   cmp ecx, dword 2
   je return

   dec ecx
   push ecx
   add ebx, 4
   push ebx
   call sorthem
   pop ebx
   pop ecx
   mov [O], ecx     ;num of disk in [O]
   mov ecx, dword 1
   mov esi, ebx
   LOOPP:
      mov edx, dword 0
      mov ebx, esi
      LOOPP2:
          mov eax, dword [ebx]
          cmp eax, dword [ebx+4]
          jb LOOPP3
          jmp LOOPP4
          LOOPP3:
              mov eax, dword [ebx+4]
              mov edi, dword [ebx]
              mov [ebx], eax
              mov [ebx+4], edi
              mov edx, dword 1
              jmp LOOPP4
          LOOPP4:
              inc ecx
              add ebx, 4
              cmp ecx, [O]
              jb LOOPP2
              cmp edx, dword 1
              je LOOPP

   return:
      mov eax, [N]
      push eax
      push arr1
      call showp
      add esp, 8

      leave
      ret



asm_main:
   enter 0,0
   pusha


   mov eax, dword [ebp+8]   ; argc
   cmp eax, dword 2         ; argc should be 2
   jne ERR1
   ; so we have the right number of arguments
   mov ebx, dword [ebp+12]  ; address of argv[]
   mov eax, dword [ebx+4]   ; argv[1]
   mov bl, byte [eax]       ; 1st byte of argv[1]
   mov [N], bl

   try1: cmp bl, '2'
   ja try2
   jb ERR2
   try2: cmp bl, '9'
   ja ERR2
   jb OK

 OK:
   mov eax, [N]
   sub eax, '0'
   mov [N], eax
   push eax
   push arr1
   call rconf
   add esp, 8
   mov eax, stat1
   call print_string
   mov eax, [N]
   push eax
   push arr1
   call showp
   add esp, 8
   mov ebx, arr1
   mov ecx, eax
   push ecx
   push ebx
   call sorthem
   pop ebx
   pop ecx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;second sort for array
   mov esi, arr1
   mov ecx, dword 1

   LOOPPP:
      mov eax, dword [esi]
      cmp eax, dword [esi+4]
      jb swap
      jmp after

      swap:
          mov ebx, dword [esi]
          mov eax, dword [esi+4]
          mov [esi], eax
          mov [esi+4], ebx

      after:
          add esi, 4
          inc ecx
          cmp ecx, [N]
          jne LOOPPP

   mov eax, [N]
   push eax
   push arr1
   call showp
   add esp, 8

   mov eax, stat2
   call print_string
   mov eax, [N]
   push eax
   push arr1
   call showp
   add esp, 8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;second sort ends



   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; test
   ;mov ebx, arr1
   ;mov ecx, dword 1
   ;LOOP:
   ;mov eax, dword [ebx]
   ;call print_int
   ;mov al, ','
   ;call print_char
   ;inc ecx
   ;add ebx, 4
   ;cmp ecx, dword 9
   ;jbe LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   jmp asm_main_end
 ERR1:
   mov eax, err1
   call print_string
   jmp asm_main_end

 ERR2:
   mov eax, err2
   call print_string
   jmp asm_main_end

 asm_main_end:
   popa
   leave                     
   ret
