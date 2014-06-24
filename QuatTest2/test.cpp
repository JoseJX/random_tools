#include <iostream>
#include <math/vector3d.h>
#include <math/quat.h>
#include "common/math.h"
#include <assert.h>

#define EMI_ORDER	Math::EO_YXZ
#define FF		(0.00001f)

#define A1		20.0f
#define	A2		20.0f
#define A3		20.0f

#define B1		30.0f
#define B2		30.0f
#define B3		30.0f

#define C1		15.0f
#define C2		0.0f
#define C3		0.0f

#define AT1		(3.03594f)
#define AT2		(-32.1139f)
#define AT3		(-28.8002f)

#define DT1		(10.7231f)
#define DT2		(7.50065f)
#define DT3		(-6.68775f)

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
	Math::Quaternion q1 = Math::Quaternion::fromXYZ(a1vec[2], a1vec[1], a1vec[0], EMI_ORDER);
	Math::Quaternion q2 = Math::Quaternion::fromXYZ(a2vec[2], a2vec[1], a2vec[0], EMI_ORDER);
	Math::Quaternion q3 = Math::Quaternion::fromXYZ(a3vec[2], a3vec[1], a3vec[0], EMI_ORDER);

//	std::cout << "Q1 - X: " << q1.x() << " Y: " << q1.y() << " Z: " << q1.z() << " W: " << q1.w() << std::endl;
//	std::cout << "Q2 - X: " << q2.x() << " Y: " << q2.y() << " Z: " << q2.z() << " W: " << q2.w() << std::endl;
//	std::cout << "Q3 - X: " << q3.x() << " Y: " << q3.y() << " Z: " << q3.z() << " W: " << q3.w() << std::endl;

	// Attach
	q1.toXYZ(&euler[2], &euler[1], &euler[0], EMI_ORDER);
	std::cout << "A1 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;

	assert(euler[0].getDegrees() - A1 < FF);
	assert(euler[1].getDegrees() - A2 < FF);
	assert(euler[2].getDegrees() - A3 < FF);

	Math::Quaternion wr = q2 * q1.inverse();
//	std::cout << "WR - X: " << wr.x() << " Y: " << wr.y() << " Z: " << wr.z() << " W: " << wr.w() << std::endl;

	wr.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "A2 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;
	
	wrvec[0] = Math::Angle(euler[0].getDegrees());
	wrvec[1] = Math::Angle(euler[1].getDegrees());
	wrvec[2] = Math::Angle(euler[2].getDegrees());

	Math::Quaternion wrq = Math::Quaternion::fromXYZ(wrvec[0], wrvec[1], wrvec[2], EMI_ORDER);

	Math::Quaternion na = q3 * wrq.inverse();
//	std::cout << "NA - X: " << na.x() << " Y: " << na.y() << " Z: " << na.z() << " W: " << na.w() << std::endl;
	na.toXYZ(&euler[0], &euler[1], &euler[2], EMI_ORDER);
	std::cout << "A3 - X: " << euler[0].getDegrees() << " Y: " << euler[1].getDegrees() << " Z: " << euler[2].getDegrees() << std::endl;
	std::cout << "RT - X: " << AT1 << " Y: " << AT2 << " Z: " << AT3 << std::endl;


	assert((euler[0].getDegrees() - AT1) < FF);
	assert((euler[1].getDegrees() - AT2) < FF);
	assert((euler[2].getDegrees() - AT3) < FF);

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
