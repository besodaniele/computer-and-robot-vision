= Mathematical concepts
Here we present some related mathematical concepts that are required for the course.
== Roto-translation
<sec:rotoTranslation>
#figure(
	image("../figures/appendix/Rigid_body_attached_frame.svg"),caption: [Rigid body attached frame. The position and orientation of a rigid body can be described by attaching a frame to it.]
)<fig:rigidBody>
Consider a rigid body as of figure @fig:rigidBody, rigid means that the points of the body do not change their relative position. The position and orientation of a rigid body can be described by attaching a frame to it. The coordinates of the points of the object are expressed in the attached frame $(x_b,y_b,z_b)$ and we would want to express them in the reference frame $(x_a,y_a,z_a)$.

In many scientific fields, the *degrees of freedom* of a system is the number of parameters of the system that may vary independently. For example, a point in the 3D space has three degrees of freedom for translation: its coordinates;
In 3D space, $n$ points have $3n$ degrees of freedom for translation. If the object is rigid, that is not the case, because the points of the object cannot move independently. In fact, a rigid body has 6 degrees of freedom: 3 for translation and 3 for rotation.

The position and orientation of a rigid body can be described by a roto-translation matrix $T$ that transforms the coordinates of the points of the object expressed in the attached frame $(x_b,y_b,z_b)$ to the reference frame $(x_a,y_a,z_a)$:
//TODO: 9:30 altre reference a immagini
The union of the position and the orientation of a rigid body is called the *pose* of the rigid body.
== Euler angles
Euler angles describe the orientation of a rigid body in space through three successive intrinsic rotations:
- *Precession ($phi$):* Rotation around the initial $z$-axis by an angle $phi$. The system $(x,y,z)$ becomes $(x',y',z')$, with $z'=z$.
- *Nutation ($theta$):* Rotation around the intermediate $x'$-axis by an angle $theta$. The system becomes $(x'',y'',z'')$, with $x''=x'$.
- *Proper rotation ($psi$):* Rotation around the intermediate $z''$-axis by an angle $psi$. The final system is $(x''',y''',z''')$, with $z'''=z''$.
#figure(
	image("../figures/appendix/euler.png"),caption: [Euler angles. The orientation of a rigid body in space can be described through three successive intrinsic rotations: precession, nutation and proper rotation.]
)
== Roll, pitch and yaw angles
Roll, pitch and yaw angles describe the orientation of a rigid body in space through three successive extrinsic rotations: Roll, pitch and yaw.
#figure(
	image("../figures/appendix/roll_pitch_yaw.png",width: 60%),caption: [Roll, pitch and yaw angles.]
)
== Roto-translation matrix
Let's combine the translation and rotation of a rigid body in a single transformation matrix $T$ called roto-translation matrix, which represents the relative pose between the relative frame of the object and the reference frame.

Take for example a frame $O"-"z y x$, we rotate it around the $z$-axis by an angle $alpha$, we can say that $alpha$ is the value of one of the degrees of the change of orientation between the two frames.
$ x'= vec( cos alpha, sin alpha , 0 ) quad y'= vec( -sin alpha, cos alpha , 0 ) quad z'= vec( 0, 0, 1 ) $
Then, the rotation matrices are defined as:
$ R_z (alpha) = mat( cos alpha, -sin alpha, 0; sin alpha, cos alpha, 0; 0, 0, 1 )\ R_y (beta) = mat( cos beta, 0, sin beta; 0, 1, 0; -sin beta, 0, cos beta ) \ R_x (gamma) = mat( 1, 0, 0; 0, cos gamma, -sin gamma; 0, sin gamma, cos gamma ) $
We postmultiply the coordinates of a point expressed in the frame $O"-"z y x$ by the rotation matrix to obtain the coordinates of the point expressed in the rotated frame $O"-"z' y' x'$.
If we compose the rotations, we can compute one after the other, for example, we can first rotate around the $z$-axis and then around the $y$-axis:
$ vec( x'',y'',z'' ) = R_y (beta) R_z (alpha) vec( x,y,z ) $
// TODO: capire se la parte ortonormale serve

We can represent translation and rotation in a single transformation matrix $T$ called roto-translation matrix, which represents the relative pose between the relative frame of the object and the reference frame.
To do this, we can use homogeneous coordinates, which allow us to represent both rotation and translation in a single matrix.
So given a point $p=vec(x,y,z)$ we have $tilde(p) = vec(w_1,w_2,w_3,w_4)$ with $ w_1 = x/w_4, w_2 = y/w_4, w_3 = z/w_4 $ and we can express the roto-translation as:
$ tilde(p)^0 = A_1^0 tilde(p)^1 $
with $ A_1^0 = mat( R_1^0, o_1^0; 0^T, 1 ) $
where $R_1^0$ is the rotation matrix from frame 1 to frame 0, and $o_1^0$ is the translation vector of the origin of frame 1 with respect to frame 0.
The rotation gives three degrees of freedom, while the translation gives three more degrees of freedom, for a total of six degrees of freedom for a rigid body.