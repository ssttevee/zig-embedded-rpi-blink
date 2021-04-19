.macro ADR_REL register, symbol
	adrp	\register, \symbol
	add	\register, \register, #:lo12:\symbol
.endm

.equ _core_id_mask, 0b11
.equ _boot_core_id, 0

.section .text.boot

_start:
	// Only proceed on the boot core. Park it otherwise.
	mrs	x1, MPIDR_EL1
	and	x1, x1, _core_id_mask
	ldr	x2, _boot_core_id
	cmp	x1, x2
	b.ne	_park

	// If execution reaches here, it is the boot core.

	// Set the stack pointer.
	ADR_REL	x0, __boot_core_stack_end_exclusive
	mov	sp, x0

	// Enter zig code.
	b	_enter_zig

	// Infinitely wait for events (aka "park the core").
_park:
	wfe
	b	_park

.size	_start, . - _start
.type	_start, function
.global	_start

.type	_park, function
.global	_park
