#include <iostream>
#include "quaternion.h"

#define rad(x) ((x / 180.0f) * M_PI)
#define deg(x) ((x * 180.0f) / M_PI)

int main(void) {
	float ef[3];
	irr::core::vector3df euler;

	float a1vec[3] = { 0.0f, 0.0f, 0.0f };
	float a2vec[3] = { 20.0f, 20.0f, 20.0f };
	float a3vec[3] = { -120.0f, 0.0f, 0.0f };

	// My Euler coordinates as Quaternions
	irr::core::quaternion q1(rad(a1vec[0]), rad(a1vec[1]), rad(a1vec[2]));
	irr::core::quaternion q2(rad(a2vec[0]), rad(a2vec[1]), rad(a2vec[2]));
	irr::core::quaternion q3(rad(a3vec[0]), rad(a3vec[1]), rad(a3vec[2]));
	
	// Attach
	q1.toEuler(euler);
	euler.getAs3Values(ef);
	std::cout << "A1 - X: " << (ef[0] * 180.0f)/M_PI << " Y: " << (ef[1] * 180) / M_PI << " Z: " << (ef[2] * 180) / M_PI << std::endl;

	irr::core::quaternion wr = q1.makeInverse() * q2;
	wr.toEuler(euler);
	euler.getAs3Values(ef);
	std::cout << "A2 - X: " << (ef[0] * 180.0f)/M_PI << " Y: " << (ef[1] * 180) / M_PI << " Z: " << (ef[2] * 180) / M_PI << std::endl;

	irr::core::quaternion na = q2.makeInverse() * q3;
	na.toEuler(euler);
	euler.getAs3Values(ef);
	std::cout << "A3 - X: " << (ef[0] * 180.0f)/M_PI << " Y: " << (ef[1] * 180) / M_PI << " Z: " << (ef[2] * 180) / M_PI << std::endl;

	// Detach
	irr::core::quaternion da = na * q2.makeInverse();
	da.toEuler(euler);
	euler.getAs3Values(ef);
	std::cout << "D3 - X: " << (ef[0] * 180.0f)/M_PI << " Y: " << (ef[1] * 180) / M_PI << " Z: " << (ef[2] * 180) / M_PI << std::endl;
	
	return 0;
}
