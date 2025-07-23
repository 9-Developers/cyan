#include "entity/entity.h"
#include <gtest/gtest.h>

TEST(cyan_entity, EntityID) {
  ASSERT_EQ(0, cyan::entity::EntityID()) << "EntityID() should return 0";
  ASSERT_EQ(1, cyan::entity::EntityID()) << "EntityID() should return 1";
  ASSERT_EQ(2, cyan::entity::EntityID()) << "EntityID() should return 2";
}
