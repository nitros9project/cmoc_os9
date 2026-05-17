
#ifndef _MAT_H
#define _MAT_H

/**
 * @file mat.h
 * @brief Legacy dense-matrix helper type and operations.
 */

/**
 * @brief Heap-allocated dense matrix with row-major storage.
 */
typedef struct {
   /** Number of rows. */
   int      m_rows, m_cols;
   /** Flexible matrix element storage. */
   double   m_value[1];
   } MAT;


/**
 * @brief Return the cofactor value for a matrix element.
 */
double   m_cofactor(), m_determinant();
/**
 * @brief Copy, create, transform, or solve matrices.
 */
MAT      *m_copy(), *m_create(), *m_invert(), *m_transpose(),
         *m_multiply(), *m_solve(), *m_add(), *m_sub(), *m_read();

/** @brief Access one matrix element by row and column. */
#define  m_v(m, r, c)   (m->m_value[r * (m->m_cols) + c])
/** @brief Null matrix pointer constant. */
#define  M_NULL         ((MAT *)0)

#endif
