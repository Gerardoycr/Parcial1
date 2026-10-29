;; @details : Programa que lee dos dígitos decimales (0-9), verifica que estén en el rango válido, calcula su suma y muestra el resultado
;; @brief : Implementación en IA-32 para Linux usando sys_read, sys_write e int 0x80 con control de errores de rango

section .data
    msg1    db "Ingresa el primer digito (0-9): "
    len1    equ $ - msg1
    msg2    db "Ingresa el segundo digito (0-9): "
    len2    equ $ - msg2
    msg_res db "La suma es: "
    len_res equ $ - msg_res
    msg_err db "Error: Numero fuera de rango (0-9). Terminando programa.", 10
    len_err equ $ - msg_err

section .bss
    dig1          resb 2        
    dig2          resb 2        
    resultado_str resb 4        

section .text
global _start

_start:
    ; --- PRÓLOGO ---
    push ebp
    mov ebp, esp
    sub esp, 4                  

    ; 1. Mostrar mensaje para el primer dígito
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, len1
    int 0x80

    ; 2. Leer el primer dígito desde el teclado
    mov eax, 3
    mov ebx, 0
    mov ecx, dig1
    mov edx, 2
    int 0x80

    ; --- VALIDACIÓN DE RANGO PARA EL DÍGITO 1 ---
    mov al, [dig1]
    cmp al, '0'                 
    jl .error_range
    cmp al, '9'                 
    jg .error_range
    sub al, '0'                 
    movzx eax, al
    mov [ebp - 4], eax          

    ; 3. Mostrar mensaje para el segundo dígito
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, len2
    int 0x80

    ; 4. Leer el segundo dígito desde el teclado
    mov eax, 3
    mov ebx, 0
    mov ecx, dig2
    mov edx, 2
    int 0x80

    ; --- VALIDACIÓN DE RANGO PARA EL DÍGITO 2 ---
    mov bl, [dig2]
    cmp bl, '0'                 
    jl .error_range
    cmp bl, '9'                 
    jg .error_range
    sub bl, '0'                 

    ; --- CUERPO / OPERACIÓN ARITMÉTICA ---
    mov eax, [ebp - 4]          
    add al, bl                  
    movzx eax, al
    mov [ebp - 4], eax          

    ; Mostrar mensaje de resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, len_res
    int 0x80

    ; Convertir el resultado numérico a cadena ASCII
    mov eax, [ebp - 4]
    cmp eax, 10
    jge .dos_digitos

    ; --- CASO: UN DÍGITO (0 - 9) ---
    add eax, '0'
    mov [resultado_str], al
    mov byte [resultado_str + 1], 10  

    mov eax, 4
    mov ebx, 1
    mov ecx, resultado_str
    mov edx, 2
    int 0x80
    jmp .fin

.dos_digitos:
    ; --- CASO: DOS DÍGITOS (10 - 18) ---
    xor edx, edx
    mov ecx, 10
    div ecx                     

    add al, '0'
    mov [resultado_str], al
    add dl, '0'
    mov [resultado_str + 1], dl
    mov byte [resultado_str + 2], 10

    mov eax, 4
    mov ebx, 1
    mov ecx, resultado_str
    mov edx, 3
    int 0x80
    jmp .fin

.error_range:
    ; --- MANEJO DE ERROR DE RANGO ---
    mov eax, 4
    mov ebx, 1                  
    mov ecx, msg_err
    mov edx, len_err
    int 0x80

    ; Terminar el programa inmediatamente (sys_exit con código de error 1)
    mov eax, 1
    mov ebx, 1
    int 0x80

.fin:
    ; --- EPÍLOGO ---
    mov esp, ebp
    pop ebp

    ; Salir del programa con éxito (código 0)
    mov eax, 1
    xor ebx, ebx
    int 0x80
