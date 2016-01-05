//
//  main.cpp
//  AODV
//
//  Created by Yu Tian on 12/8/15.
//  Copyright © 2015 Yu Tian. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>
#include <vector>

int main(int argc, const char * argv[]) {
    std::ifstream infile;
    std::ofstream outfile;
    std::string line;
    int s_c = 0, r_c = 0, d_c = 0, f_c = 0;
    int AGT_c = 0, RTR_c = 0, LL_c = 0, MAC_c = 0, PHY_c = 0;
    int overhead_c = 0;
    int bytes_rc = 0, bytes_sc = 0, bytes_dc = 0, bytes_fc = 0;
    
    infile.open("aodv_udp1.txt");
    if (!infile) {
        std::cerr << "Cannot open input file." << std::endl;
        return 1;
    }
    outfile.open("output1.txt");
    while (getline(infile, line)) {
        if (line.at(0) == 's' || line.at(0) == 'r' || line.at(0) == 'D' || line.at(0) == 'f') {
            std::istringstream iss(line);
            std::vector<std::string> tokens;
            copy(std::istream_iterator<std::string>(iss),
                 std::istream_iterator<std::string>(),
                 back_inserter(tokens));
//            std::cout << tokens.at(6) << "\n";
            // count the sent, received, dropped and forwarded
            if (tokens.at(0) == "s" && tokens.at(6) == "cbr" && tokens.at(2) == "_0_") {
                s_c++;
//                tokens.at(7) >> output;
                bytes_sc += std::stoi(tokens.at(7));
            } else if (tokens.at(0) == "r" && tokens.at(6) == "cbr" && tokens.at(2) == "_9_") {
                r_c++;
                bytes_rc += std::stoi(tokens.at(7));
            } else if (tokens.at(0) == "D" && tokens.at(6) == "cbr") {
                d_c++;
                bytes_dc += std::stoi(tokens.at(7));
            } else if (tokens.at(0) == "f") {
                f_c++;
                bytes_fc += std::stoi(tokens.at(7));
            }
            
            // type: the packet type
            // cbr - CBR data stream packet
            // DSR - DSR routing packet
            // RTS - RTS packet generated by MAC 802.11
            // ARP - link layer ARP packet
            // other than cbr, the rest are all considered as overhead
            if (tokens.at(6) == "message" || tokens.at(6) == "AODV" || tokens.at(6) == "DSR") {
                overhead_c += std::stoi(tokens.at(7));
            }
            
            // cout layers: AGT - application
            //              RTR - routing
            //              LL - link layer
            //              MAC - mac
            //              PHY - physical
            //              IFQ - outgoing packet queue (between link and mac layer)
            if (tokens.at(3) == "AGT") {
                AGT_c++;
            } else if (tokens.at(3) == "RTR") {
                RTR_c++;
            } else if (tokens.at(3) == "LL") {
                LL_c++;
            } else if (tokens.at(3) == "MAC") {
                MAC_c++;
            } else if (tokens.at(3) == "PHY") {
                PHY_c++;
            }
            
        }
//        outfile << line << "\n";
    }
    
    outfile << "Total bytes of sent: " << bytes_sc << " Bytes\n";
    outfile << "Total bytes of received: " << bytes_rc << " Bytes\n";
    outfile << "Total bytes of forwarded: " << bytes_fc << " Bytes\n";
    outfile << "Total bytes of dropped: " << bytes_dc << " Bytes\n";
    outfile << "Throughput ratio: " << long(bytes_rc / bytes_sc) * 100 << "%\n";
    outfile << "Data dropped ratio: " << bytes_dc / bytes_sc * 100 << "%\n";
    outfile << "Overhead: " << overhead_c << " Bytes\n";
    outfile << "Layer:\n";
    outfile << "AGT - application: " << AGT_c << "\n";
    outfile << "RTR - routing: " << RTR_c << "\n";
    outfile << "LL - link layer: " << LL_c << "\n";
    outfile << "MAC - mac: " << MAC_c << "\n";
    outfile << "PHY - physical: " << PHY_c << "\n";
    
    
    return 0;
}
