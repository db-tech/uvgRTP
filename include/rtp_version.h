#pragma once

#include <cstdint>
#include <string>

namespace uvgrtp {
std::string getUvgRTPVersion();
uint16_t getUvgRTPVersionMajor();
uint16_t getUvgRTPVersionMinor();
uint16_t getUvgRTPVersionPatch();
std::string getGitHash();
} // namespace uvgrtp
