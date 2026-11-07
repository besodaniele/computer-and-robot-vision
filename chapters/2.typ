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
== Epipolar geometry
We now move on to study the geometry of stereo in its full generality. This will enable us
to clarify what information is needed in order to perform the search for corresponding elements only along image lines. First of all, we need to establish some basic notations.
#figure(image("../figures/2/epipolarGeometry.png",width: 100%),caption:[Epipolar geometry.])<fig:epipolarGeometry>
@fig:epipolarGeometry shows: 
- two pinhole cameras
- their projection centers $O_l$ and $O_r$
- and image planes $pi_l$ and $pi_r$
- focal lengths are denoted by $f_l$ and $f_r$.
As usual, each camera identifies a 3-D
reference frame, the origin of which coincides with the projection center, and the $Z$-axis
with the optical axis.
The vectors$ P_l = [X_l, Y_l, Z_l]^T$ and $P_r = [X_r, Y_r, Z_r]^T$ refer to the same 3-D point, P, thought of as a vector in the left and right camera reference frames respectively.
The vectors $p_l = [x_l, y_l, z_l]^T$ and $p_r = [x_r, y_r, z_r]^T$ refer to the projections of P onto the left and right image plane respectively, and are expressed in
the corresponding reference frame.
Clearly, for all the image points we have
$z_l = f_l$ or $z_r = f_r$.

The reference frames of the left and right cameras are related via the extrinsic parameters.
These define a rigid transformation in 3-D space, defined by a translation vector, $T = (O_r,O_l)$, and a rotation matrix $R$.
Given a point $P$ in space, the relation between
$P_l$ and $P_r$ is therefore
$  P_r = R (P_l - T) $<eq:epipolarGeometryCorrespondence>
We denote the left and right epipole by $e_l$ and $e_r$, respectively. By construction, the left epipole is the image of the projection center of the right camera and vice versa.
#remark[If the line through the centers of projection is parallel to one of the image planes (i.e. we are in a rectified configuration), the corresponding epipole is the point at infinity of that line]
The relation between a point in 3-D space and its projections is described by the usual equations of perspective projection.

The practical importance of epipolar geometry stems from the fact that the plane identified by $P, O_i$, and $O_r$, called epipolar plane, intersects each image in a line, called epipolar line.

Consider the triplet $T, p_l$, and $p_r$. Given $p_l$, $P$ can lie
anywhere on the ray from $O_l$ through $p_l$.
But, since the image of this ray in the right image is the epipolar line through the corresponding point, $p_r$, the correct match must lie on the epipolar line (*epipolar constraint*).
#remark[Since all rays include the projection center by construction, this also proves that all the epipolar lines go through the epipole.]
So, if we determine the mapping between points on, say, the left image and corresponding epipolar lines on the right image, we can restrict the search for the match of $p_l$ along the corresponding epipolar line. The search for correspondences
is thus reduced to a 1-D problem.
Alternatively, the same knowledge can be used to
verify whether or not a candidate match lies on the corresponding epipolar line. 
#remark[This is usually a most effective procedure to reject false matches due to occlusions.]
=== The essential matrix
The equation ol the epipolar plane through $P$ can be written as the coplanarity condition of the vectors $P_l, T,$ and $P_l - T$, or
$  (P_l - T)^T T times P_l = 0 $
By the relation defined in @eq:epipolarGeometryCorrespondence, we can rewrite this as
$ (R^T P_r)^T T times P_l = 0 $
A vector product can be written as a multiplication by a rank-deficient matrix, we can write
$ T times P_l = S P_l \ 
"where" S = mat(0, -T_z, T_y; T_z, 0, -T_x; -T_y, T_x, 0) $
Then, we can write the coplanarity condition as
$ P_r^T E P_l = 0 "with" E = R S $

#note[By construction, S has always rank 2.]
The matrix $E$ is called the *essential
matrix* and establishes a natural link between the epipolar constraint and the extrinsic parameters of the stereo system.

By dividing by $Z_r Z_l$ we can write the epipolar constraint in terms of the image coordinates $p_r$ and $p_l$, as $ p_r^T E p_l = 0 $<eq:essentialMatrix>
Please note that if one point is known, we have a system with 2 coordinates parameters from the other point (the third one is $f$) and the unknowns from the essential matrix (5 parameters). 
Therefore, from the system we obtain a line, which is the epipolar line.
$E p_l$ is the projective line in the right plane, $u_r$, that goes through $p_r$ and the epipole $e_r$.
$ u_r = E p_l $
Notice that the whole discussion used coordinates in the camera reference frame, but what we actually measure from images are pixel coordinates. Therefore, in order to be able to
make profitable use of the essential matrix, we need to know the transformation from camera coordinates to pixel coordinates, that is, the intrinsic parameters. This limitation is removed in the next section, but at a price.
=== The fundamental matrix
We now show that the mapping between points and epipolar lines can be obtained from corresponding points only, with no prior information on the stereo system.
Let $M_l$ and $M_r$ be the matrices of the intrinsic parameters of the left and right cameras, respectively. 
if $overline(p)_l$ and $overline(p)_r$ are the pixel coordinates of $p_l$ and $p_r$ in camera coordinates, we have
$ p_l = M_l^(-1)overline(p)_l \
p_r = M_r^(-1)overline(p)_r $
By substituting these relations into @eq:essentialMatrix, we can write the epipolar constraint in terms of pixel coordinates as 
$ overline(p)_r^T F overline(p)_l = 0 "where" F = M_r^(-T) E M_l^(-1) $<eq:fundamentalMatrix>
We call $F$ the *fundamental matrix* of the stereo system.
As with $E p_l$, $F overline(p)_l$ can be thought
of as the equation of the projective epipolar line, $overline(u)_r$, that correspond to the point $overline(p)_l$, or
$ overline(u)_r = F overline(p)_l $
The difference between $u_r$ and $overline(u)_r$ and between the essential and fundamental matrices, is that the fundamental matrix is defined in terms of pixel coordinates, the essential matrix in terms of camera coordinates. Consequently, if you can
estimate the fundamental matrix from a number of point matches in pixel coordinates, you can reconstruct the epipolar geometry with no information at all on the intrinsic or extrinsic parameters.
=== Computing the essential and fundamental matrices: the 8-point algorithm
Of the various methods possible, the eight-point algorithm is by far the simplest.
We consider here the fundamental matrix only.
The idea behind the eight-point algorithm is very simple. Assume that you have been able to establish $n$ point correspondences between the images. Each correspondence gives you a homogeneous linear equation as in @eq:fundamentalMatrix for the nine entries of $F$, we obtain an homogeneous linear system.
If you have at least eight correspondences ($n > 8$) and the $n $points do not form degenerate configurations, the nine entries of F can be determined as the nontrivial solution of the system.
Since the system is homogeneous, the solution is unique up to a signed scaling factor. If one uses more than eight points, so that the system is overdetermined, the solution can once again be obtained by means of SVD related techniques (like in camera calibration). If $A$ is the system’s matrix and
$A = U D V^T$, the solution is the column of $V$ corresponding to the only null singular value of $A$.

The estimated fundamental matrix is almost certainly nonsingular (which is a requirement for a valid fundamental matrix). We can enforce the singularity constraint by adjusting the entries of the estimated matrix F.

// TODO: aggiungere commenti su numero di condizionamento
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

== Overview of the stereoscopic pipeline
#figure(image("../figures/2/recap.png",width: 100%),caption:[General pipeline of a stereoscopic system.])
#remark[In stereo, calculating the extrinsic parameters means calculating the intersection of the projection lines. Also keep in mind that the world reference frame must be the same for the two cameras. e.g. in Zheng calibration the checkboard must be seen by both cameras, and the world reference frame is the checkboard reference frame.]
=== Rectification
Using the information from the calibration step:
1. remove the distortion from the lenses
2. turn the stereo pair in standard form (rectification)
#figure(image("../figures/2/rectification.png",width: 80%),caption:[Rectification of a stereo pair.])
=== Correspondence
1. find the corresponding points in the two images (stereo matching)
2. calculate the disparity for each point and output the disparity map
The disparity map may be more or less dense, which also depends on the depth of the scene.
#figure(image("../figures/2/disparityMap.png",width: 80%),caption:[Disparity map of a scene.])

==== Difficulties of stereo matching 
These factors make the correspondence problem difficult to solve:
- Photometric distorsions and noise
- Specular surfaces
- Foreshortening: might be difficult to uniquely identify a point if nearby points are projected in the same position
- Perspective distortions
- Uniform/ambiguous regions
- Transparent surfaces
- Occlusions: some points are visible in one image but not in the other
=== Triangulation
Given the disparity map, the baseline and the focal length (which comes from calibration), triangulation computes the position of the correspondence in the 3D space, and outputs a point cloud or a depth map.
#figure(image("../figures/2/triangulation.png",width: 80%),caption:[Triangulation of a point in the scene.])
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
The* reconstruction error* does not depend on the distance from the baseline only, but is also a function of the baseline.
The larger the baseline, the less elongated, with respect to the depth, is the triangle $C'C''P$, and therefore the more accurate the reconstruction. 
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
- epipolar lines are not horizontal with the same $v$ (or $y$) coordinate
Disparity is a vector function with two components $Delta_u (u,v), Delta_v (u,v)$, each is a function of the coordinates $(u,v)$ of the primary point, the corresponding point of $(u_a,v_a)$ will have coordinates $(u_a + Delta_u(u,v), v_a + Delta_v(u,v))$.

In rectified cameras, disparity has one component $Delta_u (u,v)$, and the corresponding point of $(u_a,v_a)$ will have coordinates $(u_a + Delta_u(u,v), v_a)$. 

Of course, it is biunivocally related to the depth. In general, disparity is higher for points that are closer to the camera, and lower for points that are farther away. This is because the projections of closer points will be more separated in the two images, while the projections of farther points will be closer together.

Given a stereo rig with baseline $b$ and focal length $f$, the range field of the system is constrained by the disparity range $[d_min, d_max]$.
#figure(image("../figures/2/disparityConstraint.png",width: 80%),caption:[The disparity range constrains the depth range of the system.])

But how can we represent the disparity of a pixel?
Just by the nature of digitalization, the value will be discrete, then, we can define the plane of all the points with such disparity (all planes will be parallel). This poses a limitation in the ability to reconstruct a scene, as we can only reconstruct points that lie on these planes. 
#figure(image("../figures/2/disparityPlanes.png",width: 80%),caption:[The disparity planes are parallel and discrete, which limits the ability to reconstruct a scene.])<fig:disparityPlanes>
As you can see in @fig:disparityPlanes, the distance between the planes is not constant, but it is a function of the depth. This means that the closer the point is to the camera, the more accurate the reconstruction will be, while the farther away the point is, the less accurate the reconstruction will be.

=== Algorithms for stereo matching
Most stereo algorithms perform (a subset of) the following steps:
1. Matching cost computation: for each pixel in the primary image, compute a cost function that measures how well it matches with pixels in the secondary image along the corresponding epipolar line.
2. Cost aggregation: aggregate the matching costs over a local neighborhood to reduce noise and improve robustness.
3. Disparity computation: select the disparity value that minimizes the aggregated cost for each pixel
4. Disparity refinement: apply post-processing techniques to refine the disparity map, such as median filtering, left-right consistency check, and sub-pixel interpolation.
We can classify the algorithms based on the type of cost function used, the size of the local neighborhood, and the type of optimization used to compute the disparity map. Some common types of algorithms are:
- Local methods: do steps 1-3, simple winner-takes-all (WTA) approach, fast but less accurate, sensitive to noise and occlusions.
- Global methods: $1 (arrow 2) arrow 3$ with global (or semi-global) reasoning.
We can also discriminate between pixel-based and feature-based methods, depending on whether they operate on individual pixels or on extracted features (e.g., corners, edges, etc.). Feature-based methods are generally more robust to noise and occlusions, but they may not provide dense disparity maps.
==== Naive
#figure(image("../figures/2/naiveStereoMatching.png",width: 100%),caption:[Naive local approach for stereo matching.])
In the naive local approach, for each point of interest in the primary image, we search for the corresponding point in the secondary image along the epipolar line. We compute a matching cost (e.g., sum of absolute differences, normalized cross-correlation) for each candidate point and select the one with the lowest cost as the match. Of course we exploit the epipolar constraint to reduce the search space from 2D to 1D.
Regarding the matching cost, it uses the Sum of Absolute Differences (SAD): computes the sum of absolute differences between the pixel intensities of the two pixels. Really simple but it is REALLY sensitive to noise (_useless_).
==== Window-based
If we want to keep a *local approach*, in order to increase the signal to noise ration (SNR), the matching costs are aggregated over a support windows.
#figure(image("../figures/2/matchingWindow.png",width: 100%),caption:[Support window for cost aggregation.])
But how do we choose the size of the support window? If it is too small, it will be sensitive to noise, if it is too large, it will be sensitive to depth discontinuities. Therefore, there is a trade-off between noise sensitivity and depth discontinuity sensitivity. We can also use adaptive support windows, which change size and shape based on the local image content, to improve the matching accuracy.
#figure(image("../figures/2/fixedW.png",width: 100%),caption:[Fixed support window for cost aggregation.])
Fixed windows (with WTA reasoning) fails in most points :
- implicitly assumes frontal parallel surfaces
	#figure(image("../figures/2/frontalParallel.png",width: 100%))
	Often violated in pratice
	#figure(image("../figures/2/frontalParallel2.png",width: 100%))
	Almost all state of the art cost aggregation strategies rely on the assumption that all the points belonging to the support share the same disparity.
- ignores depth discontinuities
  
	Implicitly assuming fontral parallel surfaces in the real scene is violated near depth discontinuities.
	#figure(image("../figures/2/depthDisco.png",width: 100%))
	Aggregating the matching costs of the two populations at different depths (aligned foreground and misaligned background (outliers)) results in the typical inaccurate localization of depth borders
	#figure(image("../figures/2/depthDisco2.png",width: 100%))
	SOA cost aggregation strategies aim at shaping the support in order to include only points with the same (unknown) disparity.
	In practice, the size of the support is done empirically.
- does not deal explicitly with uniform areas
- does not deal explicitly with repetitive patterns
==== Global
If we want to use a global (or semi-global) approach, we can search for the disparity assignment that minimizes a certain cost function over the stereo pair.
$ E(d)=E_("data")(d)+ E_("smooth")(d) $
