/*!
 * \file
 * \brief       Entity implementation.
 * \details     An ECS entity implementation.
 * \author      Ryan Porterfield <ixirsii@ixirsii.tech>
 * \since       1.0.0
 * \version     1.0.0
 * \copyright   BSD 3-Clause
 */

#include "cyan/entity/entity.h"
#include <cstdint>

namespace cyan::entity {

uint64_t EntityID() noexcept {
  static uint64_t entity_id = 0;

  return entity_id++;
}

} // namespace cyan::entity
