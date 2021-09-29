#include <iostream>
#include <fstream>
#include <iomanip>

enum {
    BUFFER_SIZE = 0xFF,
    BUFFERS_PER_ROW = 0xFF
};

int main(int argc, char** argv) {
    if(argc != 5) {
        std::cout << "Usage: "
            << argv[0] << "(input.bin) (output.c) (output.h) (var_prefix)" << std::endl;
        return 1;
    }

    std::ifstream in(argv[1], std::ios_base::in|std::ios_base::binary);
    if(!in)
        return 1;
    
    std::ofstream out(argv[2], std::ios_base::out);
    if(!out)
        return 1;
    
    std::ofstream hdr(argv[3], std::ios_base::out);
    if(!hdr)
        return 1;
            
    out << std::hex;
    
    char data[BUFFER_SIZE];
    std::streamsize row_nr = 0;
    std::streamsize bytes = 0;
    bool is_first_loop = true;

    out << "unsigned char " << argv[4] << "[] = {";
    hdr << "extern unsigned char " << argv[4] << "[];" << std::endl;
    do {
        in.read(data, BUFFER_SIZE);
        std::streamsize count = in.gcount();

        // Math on possibly unsigned integer. Check zero boundary.
        if(count > 0) {
            bytes += count;
            if(is_first_loop) {
                is_first_loop = false;
            } else {
                out << ",";
            }

            if((row_nr % BUFFERS_PER_ROW) == 0) {
                out << std::endl << "\t";
            }

            for(std::streamsize i = 0; i < (count-1); ++i) {
                out << "0x" << static_cast<unsigned int>(static_cast<unsigned char>(data[i])) << ",";
            }
            out << "0x" << static_cast<unsigned int>(static_cast<unsigned char>(data[count-1]));
        }
    } while(in);

    out << std::endl << "};" << std::endl;
    out << "unsigned long " << argv[4] << "_size = " << std::dec << bytes << ";" << std::endl;
    hdr << "extern unsigned long " << argv[4] << "_size;" << std::endl;

    return (!!out) ? 0 : 1;
}
