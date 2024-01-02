# Nanomites
Nanomites technique from nanomites.w32 virus

The term nanomite is associated with a microscopic robot. This is also the name given to the known for a long time, but still used method against reverse code engineering (RCE). Technique is also used against easy rebuilding the code of the analyzed application from the process memory dump. In simple words, this technique main idea is to replace specific instructions (usually jumps - JZ, JNZ, JC etc.) in the Assembly language into INT 3h interrupt commands defined as nanomites. During the execution of the program when hitting a nanomite, the control is transferred to a special procedure, which determines the further path of the code execution.

ethical.blue Magazine ✒️

https://ethical.blue/
