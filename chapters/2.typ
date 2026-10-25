#import "@preview/scholia:0.1.0": *
We want to perceive the world in three dimensions, in order to do this, we need more than one image of the same scene.
This is because there is one degree of freedom that is lost when we project a 3D scene onto a 2D image (unless having absolute information about the image). This degree of freedom is the depth, which is the distance of an object from the camera. In order to recover this information, we need to have at least two images of the same scene, taken from different viewpoints. This is the basic idea behind stereoscopy, which is the technique of using two images to create a perception of depth.
#figure(
	image("../figures/2/missingScale.png",width: 80%),caption:[During image formation with a single camera, the depth information is lost.]
)
In human terms, this problem might be solved if additional information is provided (previous experience etc.), but in computer vision, we need to find a way to recover this information from the images themselves. This is where stereoscopy comes into play, as it allows us to recover depth information from images taken from different viewpoints.

Two images alone are not enough, some processing is needed, for example the human brain uses the two images captured by different points of view (the two eyes) simultaneously and process them (in the chiasm).

Actually, there is no real requirement for using only two images, different techniques can be used to recover depth information from multiple images, but the basic idea is the same: using multiple images to recover depth information.
Alternately, we can use a *single camera* and *move it to different positions* to capture multiple images of the same scene. This is known as structure from motion (SfM) and is a common technique in computer vision for 3D reconstruction.
Here we focus on the case of two images, which is the most common and simplest case, and we will see how to recover depth information from them.

Consider two images, which we call primary and secondary, taken from different viewpoints. From these, we want to obtain a depth image (or point cloud), which is a 3D reconstruction of the scene.
#note[In a depth image, each pixel contains information about the *distance of the corresponding point in the scene from the camera*. In a point cloud, each point represents a 3D point in space, and the collection of points represents the 3D structure of the scene.]
== Geometric model of stereoscopy
In general, we have
- two projection planes $Pi'$ and $Pi''$
- their corresponding projection centers $C'$ and $C''$ and image center $O'$ and $O''$
- a fixation point $O$ (if any)
- a point $P$ in the scene, which is projected onto the two planes as $P'$ and $P''$.
#columns(2)[
#figure(image("../figures/2/geometry.png",width: 100%),caption:[Stereoscopic geometry.])
#colbreak()
#figure(image("../figures/2/epipolarPlane.png",width: 100%),caption:[epipolar plane.])]
The plane defined by the two projection centers $C'$ and $C''$ and the point $underline(P)$ is called the *epipolar plane* ($P,C',C''$). The points $E'$ and $E''$ are called the *epipoles*, and they are the projections of the fixation point onto the two projection planes. The line connecting the two epipoles is called the *baseline*.
This plane, can also be defined without $underline(P)$, by using the two projections ($P',C',C''$) or $(P'',C',C'')$. This is useful when we know the coordinates of the projections, but not the coordinates of the point in the scene.
#columns(2)[
#figure(image("../figures/2/standardFormGeometry.png",width: 100%),caption:[Stereoscopic geometry in standard form.])<fig:standardFormGeometry>
#colbreak()
#figure(image(
	"../figures/2/epipoleOutsidePlane.png",width: 100%),caption:[Note that the epipoles are not necessarily inside the projection planes, this is not particularly a problem.])

]
The situation shown in figure <fig:standardFormGeometry> is called the *standard form* of stereoscopy (or extreme geometry).
In this case, the two optical axes are parallel, and the two projection planes are coplanar.
We can also convert any stereoscopic geometry into the standard form by applying a suitable rotation and translation to the two projection planes. This is called *rectification* and it is a common preprocessing step in stereoscopic image processing. In order to do this, we need to know the intrinsic and extrinsic parameters of the two cameras, which can be obtained through camera calibration.

There are two main problems to face in stereoscopy:
- *Correspondence (stereo matching)*: given a point in one image $P'$, find the corresponding point $P''$ in the other image which is the projection of the same point in the scene $underline(P)$.
- *Reconstruction*: given the two projections $P'$ and $P''$, find the 3D coordinates of the point in the scene $underline(P)$.
Of these two problems, the correspondence problem is the most challenging, as it requires finding the correct match between the two images.
Regarding reconstruction, if the cameras are calibrated and we know the intersection between $overline(C'P')$ and $overline(C''P'')$, we can easily compute the 3D coordinates of the point in the scene $underline(P)$. in the case of errors, noise etc. the two lines may not intersect (they are skew), in this case we can find the point that minimizes the distance from both lines, which is a common approach in computer vision.
== The correspondence problem (stereo matching)
In order to associate two points in the two planes, we need to find a way to match them. As points (in a geometrical sense), they are not distinguishable. For this reason we use a neighborhood of pixels around the point. This is based on the fundamental hypothesis of stereoscopy, that is that corresponding points in the two images have similar neighborhoods. This is called the *similarity assumption*.
This hypothesis is not always true, as there are many situations where it fails, for example in the case of occlusions, reflections, or textureless regions. In these cases, we need to use additional information to find the correct match, such as color, texture, or motion.

This is large problem because of the large number of possible matches. For each image we extract a set of salient points $S'={P'_1, P'_2, ..., P'_n}$ and $S''={P''_1, P''_2, ..., P''_m}$, or indexes in the list of pixels.
The combinatorial problem is of size $n times m$ and is hard to solve efficiently.
After the matching we will have pairs of corresponding points $(P'_i, P''_j)$, of which we will call the left one the primary point and the right one the secondary point. The primary point is the one that we will use to find the corresponding point in the other image, which is the secondary point.
=== The role of the baseline
Consider the length of $overline(C'C'')$, $overline(C' underline(P))$ and $overline(C'' underline(P))$ the smaller $overline(C'C'')$ the more similar are the two images, therefore the correspondence problem is easier to solve. This is because the two images are taken from similar viewpoints, and therefore the projections of the same point in the scene are more likely to be similar. This is called the *baseline* of the stereoscopic system, and it is an important parameter that affects the difficulty of the correspondence problem. On the other hand, if the baseline is too small, the depth information is lost, and the quality of the reconstruction is reduced.

In general, the larger $overline(C'C'')\/overline(C' underline(P))$ (or $overline(C'C'')\/overline(C'' underline(P))$), the more precise is the reconstruction.

Since the shape generated by lines is a triangle, we call the process of finding the depth information from the two images *triangulation*. The larger the baseline, the more accurate is the triangulation, but the more difficult is the correspondence problem. Therefore, there is a trade-off between the baseline and the difficulty of the correspondence problem.
=== The reconstruction error
#columns(2)[
The* reconstruction error* does not depend only on the distance form the baseline, but is also a function of the baseline.
The larger the baseline, the less elongated, with respect to the depth, is the triangle C'C''P, and therefore the more accurate the reconstruction. 
#note[Given a baseline, the depth of the error grows *quadratically* with the depth]
#colbreak()
#figure(
	image("../figures/2/triangulationError.png",width: 50%),caption:[The reconstruction error grows quadratically with the depth.]
)
]
Also, the probability distribution function of the error can be approximated by a normal (usually the first order of Taylor), but the accuracy of a normal approximation decreases with the depth. This is a known problem in computer vision and many solutions have been proposed, some of which we will see later.
Sometimes, a skewed normal may be a better approximation.
=== Disparity
The *disparity* is the difference in the position of the projections of the same point in the two images.
#definition[Epipolar line][The *epipolar line* is the intersection of the epipolar plane with the projection plane. It is the line along which the corresponding point must lie in order to satisfy the epipolar constraint.]
#definition[Epipolar constraint][The *epipolar constraint* states that the corresponding point in the other image must lie on the epipolar line (this is because we can construct the epipolar plane from the two camera positions and the principal point on the camera plane). This is a fundamental constraint in stereoscopy, as it reduces the search space for the correspondence problem from 2D to 1D.]
In the general case (i.e. not in rectified cameras):
- camera axes are not parallel 
- epipolar lines are not horizontal with the same v/y coordinate
Disparity is a vector function with two components $Delta_u (u,v), Delta_v (u,v)$, each is a function of the coordinates $(u,v)$ of the primary point, the corresponding point of $(u_a,v_a)$ will have coordinates $(u_a + Delta_u(u,v), v_a + Delta_v(u,v))$.

In rectified cameras, disparity has one component $Delta_u (u,v)$, and the corresponding point of $(u_a,v_a)$ will have coordinates $(u_a + Delta_u(u,v), v_a)$. 
// TODO: is rectification the same as being in the standard form? If not, what is the difference?
