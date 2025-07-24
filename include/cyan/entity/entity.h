/*!
 * \file
 * \brief       Entity interface.
 * \details     An ECS entity interface.
 * \author      Ryan Porterfield <ixirsii@ixirsii.tech>
 * \since       1.0.0
 * \version     1.0.0
 * \copyright   BSD 3-Clause
 */

#ifndef _CYAN_ENTITY_ENTITY_H_
#define _CYAN_ENTITY_ENTITY_H_

#include <cstdint>

/*!
 * \namespace cyan::entity
 * \brief     Entity interface.
 */
namespace cyan::entity {

/*!
 * \brief     A component that has 2 (x and y) values.
 * \tparam T  The vector type.
 */
template<typename T> struct Vector2 {
  /*! \brief  X-value. */
  T x;
  /*! \brief  Y-value. */
  T y;
};

/*!
 * \brief     A component that has 3 (x, y, and z) values.
 * \tparam T  The vector type.
 */
template<typename T> struct Vector3 {
  /*! \brief  X-value. */
  T x;
  /*! \brief  Y-value. */
  T y;
  /*! \brief  Z-value. */
  T z;
};

/*!
 * \brief     A component that has 4 (x, y, z, and w) values.
 * \tparam T  The vector type.
 */
template<typename T> struct Vector4 {
  /*! \brief  X-value. */
  T x;
  /*! \brief  Y-value. */
  T y;
  /*! \brief  Z-value. */
  T z;
  /*! \brief  W-value. */
  T w;
};

/*!
 * \brief   Get an Entity ID.
 * \return  New Entity ID
 */
uint64_t EntityID() noexcept;

} // namespace cyan::entity

#endif // _CYAN_ENTITY_ENTITY_H_
