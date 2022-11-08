;-------------------------------------------------+
; Nanomites anti-dump technique example           ;
; (general idea, primitive educational prototype) ;
;-------------------------------------------------+
; Code: Dawid Farbaniec // ethical.blue Magazine  ;
;-------------------------------------------------+

extrn ExitProcess : proc
extrn MessageBoxA : proc
extrn SetUnhandledExceptionFilter : proc

;jump types
jumpTypeJZ  equ 0
jumpTypeJNZ equ 1
jumpTypeJE  equ jumpTypeJZ
jumpTypeJNE equ jumpTypeJNZ
;(...) etc.

;jump information structure
NanomiteStruct struct
JumpType dq ?
SavedFlags db ?
JumpAddress dq ?
NextInstructionAddress dq ?
NanomiteStruct ends

;create nanomite macro
nanomite_here macro _type, _address
lahf
mov nano.JumpType, _type
mov nano.SavedFlags, ah
mov rax, offset _address 
mov nano.JumpAddress, rax
mov rax, offset @f
mov nano.NextInstructionAddress, rax 
int 3h ;nanomite
@@:
endm

.data
szCaption db "ethical.blue", 0
szTextYes db "Nanomite executed.", 0
szTextNo db "Nanomite NOT executed.", 0
nano NanomiteStruct <0, 0, 0, 0>

.code

;this procedure is called by INT 3h
myExceptionHandler proc

cmp nano.JumpType, jumpTypeJZ
jne @f
jmp _JZ

@@:
cmp nano.JumpType, jumpTypeJNZ
jne _return

_JNZ:
mov rcx, nano.JumpAddress
mov ah, nano.SavedFlags
and ah, 40h
cmp ah, 0h
jz _go
jmp _return

_JZ:
mov rcx, nano.JumpAddress
mov ah, nano.SavedFlags
and ah, 40h
cmp ah, 40h
jz _go
jmp _return

_go:
jmp rcx
jmp _return

_return:
jmp nano.NextInstructionAddress

myExceptionHandler endp

Main proc
    sub rsp, 28h

    mov rcx, myExceptionHandler
    call SetUnhandledExceptionFilter
    add rsp, 28h

    mov rax, 07h
    cmp rax, 02h

    nanomite_here jumpTypeJNZ, _executed

    jmp _notexecuted

    _executed:
    lea rdx, szTextYes
    jmp _msgbox

    _notexecuted:
    lea rdx, szTextNo

    _msgbox:
    sub rsp, 28h
    xor r9, r9
    lea r8, szCaption
    ;RDX ustawiony wcześniej
    xor rcx, rcx
    call MessageBoxA

    _exit:
    xor rcx, rcx
    call ExitProcess
Main endp

end