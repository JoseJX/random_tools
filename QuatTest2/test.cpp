#include <iostream>
#include <math/vector3d.h>
#include <math/quat.h>
#include "common/math.h"
#include <assert.h>

// X #define EMI_ORDER	Math::EO_XYZ
// X #define EMI_ORDER	Math::EO_XZY
// #define EMI_ORDER	Math::EO_YXZ
// X #define EMI_ORDER	Math::EO_YZX
#define EMI_ORDER	Math::EO_ZYX
// #define EMI_ORDER	Math::EO_ZXY
//
#define EMI_REVORDER	Math::EO_ZXY
#define FF		(0.0001f)

#define A1		10.0f
#define	A2		20.0f
#define A3		30.0f

#define B1		40.0f
#define B2		50.0f
#define B3		60.0f

#define C1		15.0f
#define C2		25.0f
#define C3		35.0f

#define A2_1		(0.99301f)
#define A2_2		(38.259f)
#define A2_3		(12.2632f)

#define A3_1		(20.3432f)
#define A3_2		(-22.1591f)
#define A3_3		(-20.4607f)

#define DT1		(16.389f)
#define DT2		(35.2348f)
#define DT3		(24.0613f)

int main(void) {
	Math::Angle a1vec[3];
	a1vec[0] = Math::Angle(A1);
	a1vec[1] = Math::Angle(A2);
	a1vec[2] = Math::Angle(A3);
	Math::Angle a2vec[3];
	a2vec[0] = Math::Angle(B1);
	a2vec[1] = Math::Angle(B2);
	a2vec[2] = Math::Angle(B3);
	Math::Angle a3vec[3];
	a3vec[0] = Math::Angle(C1);
	a3vec[1] = Math::Angle(C2);
	a3vec[2] = Math::Angle(C3);

	Math::Angle wrvec[3];
	Math::Angle euler[3];

	// My Euler coordinates as Quaternions
	Math::Quaternion q1 = Math::Quaternion::fromXYZ(a1vec[0], a1vec[1], a1vec[2], EMI_ORDER);
	Math::Quaternion q2 = Math::Quaternion::fromXYZ(a2vec[0], a2vec[1], a2vec[2], EMI_ORDER);
	Math::Quaternion q3 = Math::Quaternion::fromXYZ(a3vec[0], a3vec[1], a3vec[2], EMI_ORDER);

	std::cout << "Q1 - X: " << q1.x() << " Y: " << q1.y() << " Z: " << q1.z() << " W: " << q1.w() << std::endl;
	std::cout << "Q2 - X: " << q2.x() << " Y: " << q2.y() << " Z: " << q2.z() << " W: " << q2.w() << std::endl;
	std::cout << "Q3 - X: " << q3.x() << " Y: " << q3.y() << " Z: " << q3.z() << " W: " << q3.w() << std::endl << std::endl;

	// Attach
	q1.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "A1 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;

	assert((euler[0].getDegrees() - A1) < FF);
	assert((euler[1].getDegrees() - A2) < FF);
	assert((euler[2].getDegrees() - A3) < FF);

	Math::Quaternion wr = q1.inverse() * q2;
//	std::cout << "WR - X: " << wr.x() << " Y: " << wr.y() << " Z: " << wr.z() << " W: " << wr.w() << std::endl;

	wr.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "A2 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;
	
	assert((euler[0].getDegrees() - A2_1) < FF);
	assert((euler[1].getDegrees() - A2_2) < FF);
	assert((euler[2].getDegrees() - A2_3) < FF);

	wrvec[0] = Math::Angle(euler[0].getDegrees());
	wrvec[1] = Math::Angle(euler[1].getDegrees());
	wrvec[2] = Math::Angle(euler[2].getDegrees());

	Math::Quaternion wrq = Math::Quaternion::fromXYZ(wrvec[0], wrvec[1], wrvec[2], EMI_ORDER);

	Math::Quaternion na = wrq.inverse() * q3;
//	std::cout << "NA - X: " << na.x() << " Y: " << na.y() << " Z: " << na.z() << " W: " << na.w() << std::endl;
	na.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "A3 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;

	assert((euler[0].getDegrees() - A3_1) < FF);
	assert((euler[1].getDegrees() - A3_2) < FF);
	assert((euler[2].getDegrees() - A3_3) < FF);

	Math::Quaternion naq = Math::Quaternion::fromXYZ(euler[0], euler[1], euler[2], EMI_ORDER);

	// Detach
	Math::Quaternion da = q2.inverse() * na;
//	std::cout << "DA - X: " << da.x() << " Y: " << da.y() << " Z: " << da.z() << " W: " << da.w() << std::endl;
	da.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "D3 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;
	
	assert(euler[0].getDegrees() - DT1 < FF);
	assert(euler[1].getDegrees() - DT2 < FF);
	assert(euler[2].getDegrees() - DT3 < FF);

	// Compare against naq
	Math::Quaternion danaq = q2 * naq;
	danaq.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "DANAQ - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;

	Math::Angle a4vec[3];
	a4vec[0] = Math::Angle(20.0f);
	a4vec[1] = Math::Angle(30.0f);
	a4vec[2] = Math::Angle(40.0f);
	
	Math::Quaternion q4 = Math::Quaternion::fromXYZ(a4vec[0], a4vec[1], a4vec[2], EMI_ORDER);
	std::cout << "Q4 - X: " << q4.x() << " Y: " << q4.y() << " Z: " << q4.z() << " W: " << q4.w() << std::endl;

	
	
	return 0;
}
