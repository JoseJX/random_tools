/* ResidualVM - A 3D game interpreter
 *
 * ResidualVM is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 */

// Quaternion-math originally borrowed from plib http://plib.sourceforge.net/index.html
// Which is covered by LGPL2
// And has this additional copyright note:
/*
 Quaternion routines are Copyright (C) 1999
 Kevin B. Thompson <kevinbthompson@yahoo.com>
 Modified by Sylvan W. Clebsch <sylvan@stanford.edu>
 Largely rewritten by "Negative0" <negative0@earthlink.net>
 */
// Additional changes written based on the math presented in
// http://www.swarthmore.edu/NatSci/mzucker1/e27/diebel2006attitude.pdf

#include "common/streamdebug.h"

#include "common/math.h"
#include "math/quat.h"

namespace Math {

Quaternion::Quaternion(const Matrix3 &m) {
	fromMatrix(m);
	normalize();
}

Quaternion::Quaternion(const Matrix4 &m) {
	Matrix3 m3;
	// We only use the 3x3 matrix, so take the part we're interested in
	float newMat[9] = {
		m.getValue(0, 0), m.getValue(0, 1), m.getValue(0, 2),
		m.getValue(1, 0), m.getValue(1, 1), m.getValue(1, 2),
		m.getValue(2, 0), m.getValue(2, 1), m.getValue(2, 2)
	};
	m3.setData(newMat);
	// Does the normalization
	fromMatrix(m3);
}

Quaternion::Quaternion(const Vector3d &axis, const Angle &angle) {
	float s = (angle / 2).getSine();
	float c = (angle / 2).getCosine();
	set(axis.x() * s, axis.y() * s, axis.z() * s, c);
}

Quaternion Quaternion::xAxis(const Angle &angle) {
	Quaternion q(Vector3d(1.0f, 0.0f, 0.0f), angle);
	return q;
}

Quaternion Quaternion::yAxis(const Angle &angle) {
	Quaternion q(Vector3d(0.0f, 1.0f, 0.0f), angle);
	return q;
}

Quaternion Quaternion::zAxis(const Angle &angle) {
	Quaternion q(Vector3d(0.0f, 0.0f, 1.0f), angle);
	return q;
}

Quaternion Quaternion::slerpQuat(const Quaternion& to, const float t) {
	Quaternion dst;
	float scale0, scale1;
	float flip = 1.0;
	float angle = this->dotProduct(to);

	// Make sure the rotation is the short one
	if (angle < 0.0f) {
		angle = -angle;
		flip = -1.0;
	}

	// Spherical Interpolation
	// Threshold of 1e-6
	if (angle < 1.0f - (float) 1e-6)	{
		float theta = acosf(angle);
		float invSineTheta = 1.0f / sinf(theta);

		scale0 = sinf((1.0f - t) * theta) * invSineTheta;
		scale1 = (sinf(t * theta) * invSineTheta) * flip;
	// Linear Interpolation
	} else {
		scale0 = 1.0f - t;
		scale1 = t * flip;
	}

	// Apply the interpolation
	dst = (*this * scale0) + (to * scale1);
	return dst;
}

Quaternion& Quaternion::normalize() {
	const float scale = sqrtf(square(x()) + square(y()) + square(z()) + square(w()));

	// Already normalized if the scale is 1.0
	if (scale != 1.0f)
		set(x() / scale, y() / scale, z() / scale, w() / scale);

	return *this;
}

void Quaternion::fromMatrix(const Matrix3 &m) {
	float qx, qy, qz;
	float qw = 0.25f * (m.getValue(0, 0) + m.getValue(1, 1) + m.getValue(2, 2) + 1.0f);

	if (qw != 0.0f) {
		qw = sqrtf(qw);
		qx = (m.getValue(2, 1) - m.getValue(1, 2)) / (4 * qw);
		qy = (m.getValue(0, 2) - m.getValue(2, 0)) / (4 * qw);
		qz = (m.getValue(1, 0) - m.getValue(0, 1)) / (4 * qw);
	} else {
		float sqx = -0.5f * (m.getValue(1, 1) + m.getValue(2, 2));
		qx = sqrt(sqx);
		if (sqx > 0.0f) {
			qy = m.getValue(0, 1) / (2.0f * qx);
			qz = m.getValue(0, 2) / (2.0f * qx);
		} else {
			float sqy = 0.5f * (1.0f - m.getValue(2, 2));
			if (sqy > 0.0f) {
				qy = sqrtf(sqy);
				qz = m.getValue(1, 2) / (2.0f * qy);
			} else {
				qy = 0.0f;
				qz = 1.0f;
			}
		}
	}
	set(qx, qy, qz, qw);
}

void Quaternion::toMatrix(Matrix4 &dst) const {
	float two_xx = x() * (x() + x());
	float two_xy = x() * (y() + y());
	float two_xz = x() * (z() + z());

	float two_wx = w() * (x() + x());
	float two_wy = w() * (y() + y());
	float two_wz = w() * (z() + z());

	float two_yy = y() * (y() + y());
	float two_yz = y() * (z() + z());

	float two_zz = z() * (z() + z());

	float newMat[16] = {
		1.0f - (two_yy + two_zz),	two_xy - two_wz,		two_xz + two_wy,	  0.0f,
		two_xy + two_wz,		1.0f - (two_xx + two_zz),	two_yz - two_wx,	  0.0f,
		two_xz - two_wy,		two_yz + two_wx,		1.0f - (two_xx + two_yy), 0.0f,
		0.0f,				0.0f,				0.0f,			  1.0f
	};
	dst.setData(newMat);
}

Matrix4 Quaternion::toMatrix() const {
	Matrix4 dst;
	toMatrix(dst);
	return dst;
}

Quaternion Quaternion::inverse() {
	normalize();
	return Quaternion(-x(), -y(), -z(), w());
}

Vector3d Quaternion::directionVector(const int col) const {
	Matrix4 dirMat = toMatrix();
	return Vector3d(dirMat.getValue(0, col), dirMat.getValue(1, col), dirMat.getValue(2, col));
}

Angle Quaternion::getAngleBetween(const Quaternion &to) {
	Quaternion q = this->inverse() * to;
	Angle diff(Common::rad2deg(2 * acos(q.w())));
	return diff;
}

Quaternion Quaternion::fromXYZ(const Angle &rotX, const Angle &rotY, const Angle &rotZ, EulerOrder order) {
	// First create a matrix with the rotation
	Matrix4 rot(rotX, rotY, rotZ, order);

	// Convert this rotation matrix to a Quaternion
	return Quaternion(rot);
}

void Quaternion::toXYZ(Angle *rotX, Angle *rotY, Angle *rotZ, EulerOrder order) {
	// Create a matrix from the Quaternion
	Matrix4 rot = toMatrix();

	// Convert the matrix to Euler Angles
	Angle ex, ey, ez;
	rot.getXYZ(&ex, &ey, &ez, order);

	// Assign the Angles if we have a reference
	if (rotX != nullptr)
		*rotX = ex;
	if (rotY != nullptr)
		*rotY = ey;
	if (rotZ != nullptr)
		*rotZ = ez;
}

Quaternion Quaternion::operator*(const Quaternion &o) const {
	return Quaternion(
		w() * o.x() + x() * o.w() + y() * o.z() - z() * o.y(),
		w() * o.y() - x() * o.z() + y() * o.w() + z() * o.x(),
		w() * o.z() + x() * o.y() - y() * o.x() + z() * o.w(),
		w() * o.w() - x() * o.x() - y() * o.y() - z() * o.z()
	);
}

Quaternion Quaternion::operator*(const float c) const {
	return Quaternion(x() * c, y() * c, z() * c, w() * c);
}

Quaternion& Quaternion::operator*=(const Quaternion &o) {
	*this = *this * o;
	return *this;
}

Quaternion Quaternion::operator+(const Quaternion &o) const {
	return Quaternion(x() + o.x(), y() + o.y(), z() + o.z(), w() + o.w());
}

Quaternion& Quaternion::operator+=(const Quaternion &o) {
	*this = *this + o;
	return *this;
}

bool Quaternion::operator==(const Quaternion &o) const {
	float dw = fabs(w() - o.w());
	float dx = fabs(x() - o.x());
	float dy = fabs(y() - o.y());
	float dz = fabs(z() - o.z());
	// Threshold of equality
	float th = 1E-5;

	if ((dw < th) && (dx < th) && (dy < th) && (dz < th)) {
		return true;
	}
	return false;
}

bool Quaternion::operator!=(const Quaternion &o) const {
	return !(*this == o);
}

} // End namespace Math
