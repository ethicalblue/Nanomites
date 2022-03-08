;-------------------------------------------------+
; Nanomites anti-dump technique example           ;
; (general idea, primitive educational prototype) ;
;-------------------------------------------------+
; Code: Dawid Farbaniec                           ;
;-------------------------------------------------+

extrn ExitProcess : proc
extrn MessageBoxA : proc
extrn SetUnhandledExceptionFilter : proc

;stałe reprezentujące poszczególne rodzaje skoków
jumpTypeJZ  equ 0
jumpTypeJNZ equ 1
jumpTypeJE  equ jumpTypeJZ
jumpTypeJNE equ jumpTypeJNZ
;(...) etc.

;struktura z informacjami o skoku
NanomiteStruct struct
JumpType dq ?
SavedFlags db ?
JumpAddress dq ?
NextInstructionAddress dq ?
NanomiteStruct ends

;makro tworzące nanomit w kodzie
nanomite_here macro _type, _address
lahf ;załadowanie bajtu rejestru flag do rejestru AH
mov nano.JumpType, _type ;zapisanie rodzaju skoku (JE, JNE...)
mov nano.SavedFlags, ah ;zapisanie flag do zmiennej
;zapisanie adresu skoku dokąd prowadzi
mov rax, offset _address 
mov nano.JumpAddress, rax
;zapisanie adresu instrukcji po nanomicie
mov rax, offset @f
mov nano.NextInstructionAddress, rax 
int 3h ;nanomit
@@:
endm

.data
szCaption db "haker.info", 0
szTextYes db "Nanomite executed.", 0
szTextNo db "Nanomite NOT executed.", 0
nano NanomiteStruct <0, 0, 0, 0>

.code

;procedura obsługi wyjątków (wywołuje ją instrukcja int 3h)
myExceptionHandler proc

;sprawdź rodzaj skoku (JZ, JNZ...)
cmp nano.JumpType, jumpTypeJZ
jne @f
jmp _JZ

@@:
cmp nano.JumpType, jumpTypeJNZ
jne _return

;sprawdź czy bit znacznika ZF 
;w rejestrze flag równy zero (nieustawiony)
_JNZ:
mov rcx, nano.JumpAddress
mov ah, nano.SavedFlags
and ah, 40h
cmp ah, 0h
jz _go
jmp _return

;sprawdź czy bit znacznika ZF 
;w rejestrze flag równy jeden (ustawiony)
_JZ:
mov rcx, nano.JumpAddress
mov ah, nano.SavedFlags
and ah, 40h
cmp ah, 40h
jz _go
jmp _return

;przejście do adresu gdzie prowadził skok
;(skok warunkowy wykonany)
_go:
jmp rcx
jmp _return

;przejście do kolejnej instrukcji po int 3h
;(skok warunkowy niewykonany)
_return:
jmp nano.NextInstructionAddress

myExceptionHandler endp

Main proc

;ustawienie procedury myExceptionHandler, aby obsługiwała wyjątki
sub rsp, 28h
mov rcx, myExceptionHandler
call SetUnhandledExceptionFilter
add rsp, 28h

;przykładowe instrukcje porównania wartości
mov rax, 07h
cmp rax, 02h

;nanomit zamiast skoku JNZ (makro)
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
add rsp, 28h

_exit:
sub rsp, 28h
xor rcx, rcx
call ExitProcess
Main endp

end