# GBADEV

This project aims to make gba homebrew development lighter and more accessible to modern systems.

# RAM

malloc and new calls allocate memory in EWRAM between address 0x02000000 and 0x0203FFFF (256 KB)

# Stack

The stack uses memory in IWRAM between address 0x03000000 and 0x03007FFF (32 KB)

# ROM

ROM data is accessible via memory between address 0x08000000 and 0x47FFFFFF (32 MB)
