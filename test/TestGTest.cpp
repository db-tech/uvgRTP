#include <gtest/gtest.h>
#include "rtp_version.h"

TEST(DefaultTest, ctor) {
  EXPECT_STREQ("2.0.0",uvgrtp::getUvgRTPVersion().c_str());
  EXPECT_EQ(2,uvgrtp::getUvgRTPVersionMajor());
  EXPECT_EQ(0,uvgrtp::getUvgRTPVersionMinor());
  EXPECT_EQ(0,uvgrtp::getUvgRTPVersionPatch());
}