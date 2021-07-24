#include "rtp_version.h"
#include <gtest/gtest.h>

TEST(DefaultTest, ctor) {
  EXPECT_STREQ("2.1.0", uvgrtp::getUvgRTPVersion().c_str());
  EXPECT_EQ(2, uvgrtp::getUvgRTPVersionMajor());
  EXPECT_EQ(1, uvgrtp::getUvgRTPVersionMinor());
  EXPECT_EQ(0, uvgrtp::getUvgRTPVersionPatch());
  EXPECT_STREQ("", uvgrtp::getGitHash().c_str());
}