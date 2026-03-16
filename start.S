.syntax unified
.cpu cortex-m4
.thumb

.global vtable
.global _hard_reset

.type vtable, %object
vtable:
    .word _stack_start
    .word _hard_reset + 1
    .size vtable, . - vtable

_hard_reset:
    ldr r0, =_stack_start
    mov sp, r0
    b _hard_reset
