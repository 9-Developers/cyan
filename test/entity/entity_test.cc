#include "cyan/entity/entity.h"
#include <catch2/catch_test_macros.hpp>

TEST_CASE("Entity IDs are generated", "[entity]") {
  REQUIRE(cyan::entity::EntityID() == 0);
  REQUIRE(cyan::entity::EntityID() == 1);
  REQUIRE(cyan::entity::EntityID() == 1);
}
