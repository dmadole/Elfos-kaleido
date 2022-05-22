# Elfos-kaleido

This is for the 1802 with a TMS9XXX video display processor. Build 1 is built for video on I/O ports 1 (memory) and 5 (register).

Build 2 is updated to support group selection and is built for expander port 1, group 1, ports 6 and 7. It can be rebuild for other configurations by changing the defines in the source.

This is a re-implementation of the Cromemco Dazzler kaleido program. This was created from the original kaleido 8080 machine language implementation, adapting to the 1802 instruction set and the 9918 video, and then optimizing for performance.
