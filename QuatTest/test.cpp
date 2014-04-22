#include <iostream>
#include "quaternion.h"

#define rad(x) ((x / 180.0f) * M_PI)
#define deg(x) ((x * 180.0f) / M_PI)

irr::core::quaternion e2q(irr::core::vector3df e) {
	return irr::core::quaternion(e.X, e.Y, e.Z);
}

irr::core::quaternion e2q(float f[3]) {
	return irr::core::quaternion(f[0], f[1], f[2]);
}

void print(irr::core::quaternion& q, std::string name) {
	std::cout << name << " - X: " << q.X << " Y: " << q.Y << " Z: " << q.Z << " W: " << q.W << std::endl;
	return;
}

void print(irr::core::vector3df v, std::string name) {
	std::cout << name << " - X: " << deg(v.X) << " Y: " << deg(v.Y) << " Z: " << deg(v.Z) << std::endl;
	return;
}

void print(float f[3], std::string name) {
	std::cout << name << " - X: " << deg(f[0]) << " Y: " << deg(f[1]) << " Z: " << deg(f[2]) << std::endl;
	return;
}

class Actor {
	private:
		std::string _name;
		float _pitch, _yaw, _roll;
		Actor *_attached_to;
	public:
		void setName(std::string name) { _name = name; };
		std::string getName() { return _name; };
		float getPitch() { return deg(_pitch); };
		float getYaw() { return deg(_yaw); };
		float getRoll() { return deg(_roll); };
		void setRot(float pitch, float yaw, float roll);
		irr::core::vector3df getRot() { return irr::core::vector3df(_pitch, _yaw, _roll); };
		void attach(Actor& other);
		void detach();
		irr::core::quaternion getQuat();
};

// Prints the rotation
void print(Actor& a) {
	irr::core::vector3df rot = a.getRot();
	print(rot, a.getName());
	return;
}
		
void Actor::setRot(float pitch, float yaw, float roll) {
	_pitch = rad(pitch);
	_yaw = rad(yaw);
	_roll = rad(roll);
	return;
}

irr::core::quaternion Actor::getQuat() {
	irr::core::quaternion my_q(_pitch, _yaw, _roll);
	if (_attached_to) {
		my_q = my_q * _attached_to->getQuat();
	}
	return my_q;
}

void Actor::attach(Actor& other) {
	_attached_to = NULL;
	irr::core::vector3df euler;

	irr::core::quaternion my_q(_pitch, _yaw, _roll);
	irr::core::quaternion ot_q = other.getQuat();

	irr::core::quaternion newRot = ot_q.makeInverse() * my_q;
	newRot.toEuler(euler);
	_pitch = euler.X;
	_yaw = euler.Y;
	_roll = euler.Z;
	_attached_to = &other;
	return;
}

void Actor::detach() {
	_attached_to = NULL;
	return;
}

int main(void) {
	Actor a1; a1.setName("A1"); a1.setRot(20.0f, 20.0f, 20.0f);
	Actor a2; a2.setName("A2"); a2.setRot(30.0f, 30.0f, 30.0f);
	Actor a3; a3.setName("A3");

	// Make sure all of the attached_to pointers are NULL (should make a constructor..)
	a1.detach(); a2.detach(); a3.detach();

	a2.attach(a1);
	print(a1);
	print(a2);
	std::cout << "**************************************************************" << std::endl;

	for(float i=-120; i<=120; i+=15) {
		a3.setRot(i, 0.0f, 0.0f);
		a3.attach(a2);
		print(a3);
	}
	return 0;
}
