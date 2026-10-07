#import "@preview/scholia:0.1.0": *
A camera is the union of the sensors and the software that uses the image to determine relevant points in the image plane and  the projection model.
This allows to calculate the lines connecting the points in the image plane and the object.
#note[A camera sensor (once calibrated) does not measure points in the image, but measures lines in the space (a subset of the star of lines passing trough the pinhole).]
Since we are only calculating lines, knowing the precise physical measures of the image plane is not necessary since the lines don't depend on them.
The simplest geometric model of image formation is the *pinhole camera*, it is based on the same principle as the camera obscura.

== Pinhole camera model
The tiny hole (pinhole) in one wall of the room lets in a ray of light for each point in the scene so that an image of the outside world is drawn on the opposite wall (*image plane*).
#figure(
	image("../figures/1/pinholeCamera.png",width: 80%),caption: [Image formation in the camera obscura/pinhole camera]
)
#figure(
	image("../figures/1/pinholeCamera2.png",width: 80%),caption: [Pinhole camera with virtual image]
)	

The geometric model of the camera that we will adopt is the so-called pinhole or
perspective model, which consists (refer to @fig:pinholeCamera) of the *image plane* $Q$ and the
centre of projection (*Centre of Projection, COP*) $C$, located at a distance f (*focal length*) from the image plane.
#definition[principal axis][The line through $C$ orthogonal to $Q$ is the *principal axis* of the camera ]
#definition[principal point][The intersection of the principal axis with $Q$ is called the *principal point* (or center of the image).]
#definition[focal plane][The plane $F$ parallel to $Q$ and containing $C$ is called the *focal plane*.]
The points in $F$ are projected to infinity on $Q$.
#figure(
	image("../figures/1/pinholeCamera3.png",width: 80%),caption: [Pinhole camera with virtual image]
)	<fig:pinholeCamera>
Let $M$ be a point in the scene, of coordinates $(X, Y, Z)$, and let $M$ of coordinates $(X , Y , Z )$ be its projection onto the image plane through the pinhole $C$. If $f$ is the
distance of C from the image plane (focal length), then from the similitude of the triangles we get:
$ (-X')/f = X/Z quad quad (-Y')/f = Y/Z $
therefore 
$ X' = (-f X )/Z quad quad Y' = (-f Y )/Z quad quad Z'=-f $
Note that the image is inverted with respect to the scene, both left-right and top-bottom, as indicated by the minus sign. These equations define the image formation process, which is called *perspective projection*.

The parameter $f$ determines the *magnification factor* of the image: if the image plane is close to the pinhole, the image is reduced in size, while it will become larger and larger as $f$ increases. Since the working area of the image plane is framed, moving the image plane away also reduces the *field of view*, that is the solid angle that contains the portion of the scene that appears in the image.

The division by $Z$ is responsible for the foreshortening effect, whereby the
apparent size of an object in the image decreases according to its distance from
the observer.
=== Simplified pinhole model
The coordinate system in which the points of the three-dimensional space are represented is called the *world (or object) coordinate system*.
Let us introduce the *camera reference frame*, a right-handed triplet $(X, Y, Z) $ of axes centred in $C$ and with the $Z$ axis coincident with the principal axis. In this simplified model, the world reference frame is chosen coincident with the camera reference frame.
#figure(
	image("../figures/1/simplifiedModel.png",width: 80%),caption: [Simplified model of the camera with reference frames.
	The point $M$ is projected onto the point $m $ where the line $C M$ intersects the image plane $Q$]
)<fig:simplifiedPinhole>
We also introduce a reference frame $(u, v)$ for the plane $Q$ centred at the principal point and with the axes $u$ and $v$ oriented as $X$ and $Y$ , respectively, as shown in @fig:simplifiedPinhole.
#sidenote[Unless stated otherwise, we use \~ to denote Cartesian coordinates to distinguish them from homogeneous ones.]

Now consider a point $M$ of coordinates $tilde(M)= vec(X,Y,Z)$ in 3D space and let $m$ of coordinates $tilde(m) = vec(u,v)$ be its projection onto $Q$ trough $C$.
We have that 
$ cases(u = (-f)/Z X  , ,v = (-f )/Z Y) $<eq:perspectiveProjectionPinhole> 
In @eq:perspectiveProjectionPinhole we have the intersection of two planes, therefore we obtain a line.
This is the *perspective projection*. The transformation in Cartesian coordinates is clearly non-linear because of the division by Z.
But if we use homogeneous coordinates, the transformation becomes linear. 
Let $ m= vec(u,v,1) quad M=vec(X,Y,Z,1) $
be the homogeneous coordinates of m and M, respectively.
So the equation for perspective projection, in this simplified case, rewrites:
$ Z vec(u,v,1)= z vec(-f X/Z, -f Y/Z, Z) = mat(-f, 0, 0,0; 0, -f,0,0; 0, 0, 1, 0) vec(X,Y,Z,1) $
In other words
$ m=1/Z P M $
The matrix $P$ represents the geometric model of the camera and is called *Perspective Projection Matrix (PPM)* or *camera matrix*.
=== General pinhole model
A realistic model of a camera, describing the transformation from 3D coordinates
to pixel coordinates, as well as the perspective transformation, must take
into account:
- The change of coordinates from metres in the sensor plane to pixels in the image.
- The change of coordinates between the camera reference frame and the world reference frame.
#figure(
	image("../figures/1/generalPinhole.png",width: 80%),caption: [General model of the camera with reference frames. Note that the image plane should be viewed from the half-space opposite to C, so that the origin of the image reference is in the upper left corner of the image]
)<fig:generalPinhole>
==== Intrinsic parameters
The transformation from the sensor coordinates to pixels is modelled by an affine transformation A that takes into account the translation of the origin at the upper left corner, the independent rescaling of the u and v axes for changing the unit of measurement from metres to pixels and the reversal of the direction of the axes:
$ A = mat(-k_u,0, u_0; 0, -k_v, v_0;0,0,1) $
where $(u_0 , v_0 )$ are the coordinates in pixels of the principal point and $k_u (k_v )$ (which is translated in respect to the center of the lens) is the inverse of the effective pixel size along the direction of the u (v) axis, measured in $m^(-1)$. 
// TODO principal point in the book with two different coordinates for u and v, but in the slides with a single coordinate. Ask to the professor.
The matrix $A$ transforms the coordinates from metres to pixels; hence, it pre-multiplies the PPM, which becomes:

=== Thin lenses
A pinhole camera is really small (in theory, infinitesimal) therefore the energy reaching the image plane also is. In order to obtain an image we would need a transformation rate which is, in theory, infinite and therefore impossible to obtain.
If we simply increased the size in the hole we would not be able to control the amount of energy coming to the image plane, and would therefore obtain a spot instead of a point the image plane. If this were to occur, then the image would be blurry (*circle of confusion*).

Vertebrate eyes and cameras use lenses. A lens, being larger than a pinhole, can gather more light.
Lenses allow a larger opening, so a finite amount of energy, to reach the image plane and at the same time we might be able to obtain an effect in terms of projection (zoom, etc...).
The downside is that not the whole scene can be in focus at the same time.

The approximation we make for the optics of the imaging system—
which in general is very complex, being made up of multiple lenses is that of the thin lens.
#definition[Thin lenses][Thin lenses are ideal devices that enjoy the following properties:
- The rays parallel to the optical axis incident on the lens are refracted so that they pass through a point on the optical axis called focus $F$ 
- The rays passing through the centre $C$ of the lens are unaffected.]
The distance of the focus $F$ from the centre of the lens $C$ is called *focal length* $D$, which depends on the radii of curvature of the two lens surfaces and the refractive index of the constituent material. 
#figure(
	image("../figures/1/thinLens.png",width: 80%),caption: [Thin lenses])
#note[For non-thin lenses there is no “center” of the lens, but two nodal points (front and rear) are defined to characterize its behavior. By definition, an input ray directed at the front nodal point leads to an output ray which appears to come from the back nodal point, forming the same angle with respect to the optical axis. For a thin lens, the two nodal points coincide in the centre of the lens.]
Given a point of the scene $M$ it is possible to construct graphically the image (or conjugate point) $M'$, using two special rays that depart from $M$: the ray parallel to the optical axis, which after refraction, passes through F and the ray that passes unchanged through $C$.

Due to this construction and the similitude of the triangles, we obtain the conjugate points formula (or equation of the thin lens):
$ 1/Z + 1/Z' = 1/D $<eq:conjugation>
The image of a point in the scene at distance $Z$ from the lens is produced (in focus) at a distance $Z'$, from the lens, which depends on the depth $Z$ of the point and the focal length $D$ of the lens.
#figure(image("../figures/1/conjugatePoint.png",width: 80%),caption: [Construction of the conjugate point.])
The image of the point $M$, when in focus, is formed on the image plane at the same point predicted by the pinhole model with the pinhole coincident with the centre of the lens $C$: in fact, the ray passing through $C$ is common to the two geometric constructions. The other light rays that leave M and are collected by the lens to increase the light reaching $M'$.

If @eq:conjugation is not verified one gets a blurred image of the point, that is, a circle which is named *circle of confusion*.
#note[This is the same effect that would occur by just increasing the size of the pin hole, but is caused by different physical conditions.]
The photosensitive elements have a small but finite size. 
#remark[As long as the circle of confusion does not exceed the size of the photosensitive element, the image is in focus. This is due to the *sampling theorem*.]
Therefore, there is an interval of depths for which the points are in focus. This range is called *depth of field*, which is inversely proportional to the diameter of the lens; in fact, the pinhole camera has an infinite depth of field.
The light that is collected, on the other hand, is directly proportional to the diameter of the lens.
#remark[The focal length of the lens is a different notion from the focal length of the pinhole camera. Two different notations, $f$ and $D$, were used on purpose, although, unfortunately, the two quantities have the same name.]
== Sensing
What differentiates a camera (in the modern sense of the world) from the portable camera obscura of the 17th century is its ability to record the pictures that form on its backplane.
We now introduce two different kinds of modern camera sensors.
=== CCD sensors
*Charge-coupled-device (CCD)* cameras that were proposed in 1970.
A CCD sensor uses a
rectangular grid of electron-collection sites laid over a thin silicon wafer to record a measure of the amount of light energy reaching each of them.
#figure(
	image("../figures/1/ccdSensor.png",width: 50%),caption: [A CCD Device.]
)
Each site is formed by growing a layer of silicon dioxide on the wafer and then depositing a conductive gate structure over the dioxide. When photons strike the silicon, electron-hole pairs are generated (photo-conversion), and the electron are captured by the potential well formed by applying a positive electrical potential to the corresponding gate. The electrons generated at each site are collected over a fixed
period of time $T$.

At this point, the charges stored at the individual sites are moved using charge coupling:
- Charge packets are transferred from site to site by manipulating the gate potentials, preserving the separation of the packets.
- The image is read out of the CCD one row at a time, each row being transferred in parallel to a serial output register with one element in each column.
- Between two row reads, the register transfers its charges one at a time to an output amplifier that generates a signal proportional to the charge it receives.
This process continues until the entire image has been read out. The reading time depends on the use case, varying greatly.
#note[The digital output of most CCD cameras is transformed internally into an analog video signal before being passed to a frame grabber that constructs the final digital image.]
Consumer-grade color CCD cameras essentially use the same chips as black-and-white cameras, except that successive rows or columns of sensors are made sensitive to red, green or blue light often using a filter coating that blocks the complementary light.

The spatial resolution of single-CCD cameras is of course limited, and higher-quality cameras use a beam splitter to ship the image to three different CCDs via color filters.

#figure(
	image("../figures/1/CCD2.png"),caption: [CCD image sensor pipeline]
)
#remark[The flow of electricity in CCD sensors obviously generates heat, which equals energy. The sensors pick up this heat as noise, therefore the sensors need to be cooled to reduce noise.]
=== CMOS sensors
CMOS sensors are integral to modern digital imaging, particularly in devices like smartphones, digital cameras, and high-speed industrial systems. Unlike CCD sensors, CMOS sensors process image data in a way that allows for faster operation and lower power consumption.
#figure(
		image("../figures/1/CMOS.png"),caption: [CMOS image sensor pipeline]
)
Just like in a CCD sensor, the process starts when light enters the camera lens and is focused onto the CMOS sensor. The CMOS sensor is made up of pixels arranged in a grid. Each pixel acts as a light detector, capturing photons and converting them into an electrical charge.
When photons hit the CMOS sensor, they are absorbed by the photodiodes within each pixel. This absorption generates electron-hole pairs in the silicon substrate, where each photon generates one electron. The number of electrons generated in each pixel is proportional to the intensity of the light striking that pixel. Brighter areas in the image produce more electrons, corresponding to higher brightness levels.

After the charge is converted to voltage at the pixel level, the signal is amplified to make it strong enough for further processing. This amplification occurs within the same pixel, minimizing the distance the signal has to travel, which reduces noise and improves image quality. In many CMOS sensors, the analog voltage signals are converted to digital signals at the column or even the pixel level by an integrated ADC. This localized conversion is one of the reasons CMOS sensors can achieve high-speed readouts.

One characteristic of many CMOS sensors is the *rolling shutter* effect. Because each row or column of pixels is read out sequentially rather than all at once, moving objects can appear distorted. For example, a fast-moving car might look skewed because different parts of the image are captured at slightly different times. However, advanced CMOS sensors can mitigate this effect, and some even employ a *global shutter* to capture all pixels simultaneously, similar to CCD sensors.
#note[Optimally we want a global shutter with an exposure time that doesn't lead to motion blur. ]
=== Sensor models
For simplicity, we restrict our attention in this section to black-and-white CCD cameras: Color cameras can be treated in a similar fashion by considering each color channel separately and taking the effect of the associated filter response explicitly into account.

The number $I$ of electrons recorded at the cell located at row $r $and column $c$ of a CCD array can be modeled as $ I(r,c)=T integral_lambda integral_(p in S(r,c)) E(p,lambda)R(p) q(lambda) d p space d lambda $
where $T$ is the electron-collection time and the integral is calculated over the spatial domain $S(r, c)$ of the cell and the range of wavelengths to which the CCD has a nonzero response.
In this integral:
- $E$ is is the power per unit area and unit wavelength arriving at the point $p$
-  $R$ is the spatial response of the site
-  $q$ is the quantum efficiency of the device 
#definition[Quantum efficiency of a device][The quantum efficiency of a device is the number of electrons generated per unit of incident light energy]
In general, both $E$ and $q$ depend on the light wavelength $lambda$, and $E$ and $R$ depend on the point location $p$ within $S(r, c)$.

The output amplifier of the CCD transforms the charge collected at each site into a measurable voltage. In most cameras, this voltage is then transformed into a low-pass-filtered (generally a mean) video signal by the camera electronics with a magnitude proportional to $I$.
The analog image can be once again transformed into a digital one using a frame grabber that spatially samples the video signal and quantizes the brightness value at each image point or pixel (from picture element).
#figure(
	image("../figures/1/quantumEfficiency.png",width: 50%),caption: [quantum efficiency of Hubble camera 2]
)
In addition to this, we can create a diagram that shows us the relation between the amount of energy incoming into the device (independently of the wavelength) and the "amount" of signal coming out of the device, the so-called *in/out diagram*. 
Of course, we ideally want it to be linear.
== Digital images
Here we introduce digital images and some operations that can be done on them.
=== HDR
According to exposure time, length of exposure time and the scene itself some areas of the image can be overexposed, underexposed, or correctly. We want to obtain an image in which all areas are properly exposed. This is called *High Dynamic Range (HDR)* imaging.
Of course, the approach changes whether the image is static or dynamic.
#figure(
	image("../figures/1/exposure.png",width: 80%),caption: [pictures taken with different exposure times of the same scene]
)
There are two main approaches to HDR imaging:
==== Multiple exposure
In this approach, multiple very fast and near exposures are taken on the same scene, with different exposure conditions.
These images are combined after being read from the sensor, the algorithm may be heavy and the image can be shown only after the processing is done. This may be acceptable depending on the use case.
#figure(
	image("../figures/1/dualExposure.png",width: 80%),caption: [Multiple exposure HDR imaging]
)
==== Single exposure
This works thanks to the fact that in CMOS sensors, a bit of computation can be done on the pixels themselves.
Each pixel can be read multiple times during the exposure time (each one has different "filling" times), and the values can be combined to obtain a single value for that pixel. This allows to obtain a single image with a high dynamic range.
A problem rises once the image must be read from the sensor, we could have more bits per pixel than the sensor can read.
We can linearly map the values into the range of the sensor, but this might be hard to do with a really small amount of transistors per pixel. Typically, the values are mapped into a linear-logarithmic scale, with can be easily implemented in hardware on the pixels.
#figure(
	image("../figures/1/singleExposureCompression.png",width: 80%),caption: [Single exposure HDR imaging]
)
Please note that this introduces a non-linear mapping of the values, which is a change of semantics of the values, and therefore a change of the meaning of the image.
=== Color cameras
There are different approaches to color cameras:
==== Color filter array
Typically different color channels are captured by different sensors, and the final image is obtained by combining the three channels. This is done by using a color filter array (CFA) that allows each sensor to capture only one color channel (red, green, or blue). The most common CFA is the Bayer filter, which has a pattern of red, green, and blue filters arranged in a specific way. The raw data from the sensors is then processed using a demosaicing algorithm to reconstruct the full-color image.
#figure(
	image("../figures/1/bayer.png",width: 80%),caption: [Bayer filter pattern]
)
Quantum efficiency is not defined in the same way for color cameras, since it depends on the wavelength of the light. 
The colored image is obtained by interpolating the values of the three channels, which are not sampled at the same points. This process is called *demosaicing*. There are many algorithms for demosaicing. The choice of algorithm can affect the quality of the final image, particularly in terms of color accuracy and the presence of artifacts. In general, all demosaicing algorithms introduce artifacts to some level.

Three sensors are sufficient because the color space is three-dimensional, and red, green and blue are a base of the color space.
#remark[So in practice, when creating a color image, we are sub-sampling the color channels, and then interpolating them to obtain a full-color image.]
==== 3-CCD cameras
In 3-CCD cameras, the light from the scene is split into three separate beams using a prism or dichroic mirrors, and each beam is directed to a separate CCD sensor that captures one of the primary colors (red, green, or blue). This allows for higher color fidelity and resolution compared to single-sensor cameras with color filter arrays. The three separate images are then combined to create the final color image. 3-CCD cameras are often used in professional video and photography applications. This method avoids the need for demosaicing, as each color channel is captured at full resolution, resulting in better color accuracy and reduced artifacts. But the sensor must be kept in the same position with a micrometer precision, and the prism must be aligned with the sensors. This makes the camera more expensive and less robust to shocks.
Also, some of the energy is lost in the prism, and the camera is bigger and heavier than a single-sensor camera.
#figure(
	image("../figures/1/3-CCD color camera.JPG",width: 50%),caption: [3-CCD camera]
)
==== Stacked sensors (Foveon)
Three different layers of sensors are stacked on top of each other, with each layer sensitive to a different range of wavelengths (red, green, or blue). This allows for full-color capture at each pixel location without the need for demosaicing. Stacked sensors can provide high color fidelity and resolution, but they can be more complex and expensive to manufacture compared to traditional single-layer sensors with color filter arrays.
#figure(
	image("../figures/1/foveon.jpg",width: 100%),caption: [Foveon sensor]
)
== 3D cameras
A 3D camera outputs a 4-channel image, with the first three channels being the color channels, and the fourth channel being the depth channel ($D$). The depth channel contains the distance of each pixel from the camera. This allows to obtain a 3D representation of the scene.
Alternatively, in addition to the color channels, the camera can output a 3D point cloud, which is a set of points in 3D space that represent the scene. Each point has a position in 3D space and a color value. This allows to obtain a 3D representation of the scene.
=== Time-of-flight cameras
We will focus on time-of-flight (ToF) cameras, which are a type of 3D camera that measures the distance to objects in the scene by calculating the time it takes for a signal to travel from the camera to the object and back. ToF cameras *emit a signal* and measure the time it takes for the signal to return after reflecting off objects in the scene. This time measurement is then used to calculate the distance to each point in the scene, creating a depth map.
#note[Light is fast, too fast...]
Doing a TOF camera with light is possible, but it is very expensive (LIDAR).
Some other devices work thanks to amplitude modulation, where the emitter emits a modulated signal, and the sensor measures the phase shift of the returning signal. This phase shift is proportional to the distance to the object, allowing for depth calculation.
This type of calculation is really cheap and can be done by standard hardware.
This approach also gives me control over the frequency of the signal that is emitted.
== Defects in images
Here we introduce some defects that can be present in images.
Defects can be caused by the sensor, the lens, or the environment.  
=== Defects caused by the sensor
==== Blooming
Blooming occurs when the light source illuminating a collection site is so bright that the charge stored at that site overflows into adjacent ones.
#figure(
	image("../figures/1/CCD-blooming-and-smear-a-A-CCD-captured-image-with-blooming-and-smear-b-another.webp", width: 100%),caption:[CCD blooming and smear. (a) A CCD captured image with blooming and smear, (b) another scene image with blooming and smear.]
)
==== Smear
Smear denotes the undesired bright sections above and below the bright light source, caused by charges’ accumulation of the light source during the vertical transfer process.
=== Defects caused by the lens
The field of view
of a camera is the portion of scene space that actually projects onto the retina of the camera. It
is not defined by the focal length alone, but also depends on the effective area of the retina (e.g.,
the area of film that can be exposed in a photographic camera, or the area of the CCD sensor in
a digital camera.
#figure(
	image("../figures/1/fieldOfView.png",width: 80%),caption: [Field of view of a camera]
)
Lenses can introduce distortions in the image, which generally increase with the distance from the optical axis.
Therefore, it's better to put the sensor well inside the circle in which the lens projects the image.
The most common distortions are:
- *Barrel distortion*: the image magnification decreases with distance from the optical axis, causing straight lines to appear curved outward. This is common in wide-angle lenses.
- *Pincushion distortion*: the image magnification increases with distance from the optical axis, causing straight lines to appear curved inward. This is common in telephoto lenses.
#figure(
	image("../figures/1/Barrel_distortion_pincushion_distortion-1489631190.webp",width: 80%),caption: [Lens distortion]
)	
We can also discriminate between radial and tangential distortion. Radial distortion is caused by the shape of the lens, while tangential distortion is caused by the misalignment of the lens elements.
#figure(
	image("../figures/1/tangentialRadial.png",width: 80%),caption: [Radial and tangential distortion]
)	
#figure(
	image("../figures/1/Definitions-of-radial-tangential-distortion-on-the-2-D-plane-3038096262.png",width: 80%),caption: [Definitions of radial and tangential distortion on the 2-D plane]
)
Note that both radial and tangential are a *function of the radius*, that is the distance from the optical axis. Therefore, they are both zero at the optical axis and increase with distance from it. 
// TODO ask clarification of center of image plane and optical axis to the professor
==== Chromatic aberration
Chromatic aberration is a type of distortion in which there is a failure of a lens to focus all colors to the same convergence point. It occurs because lenses have different refractive indices for different wavelengths of light, causing them to bend light of different colors by different amounts. This results in a misalignment of colors in the image, leading to color fringing around the edges of objects, especially in high-contrast areas. Chromatic aberration can be minimized by using achromatic lenses, which are designed to bring two wavelengths (typically red and blue) into focus in the same plane, or by using apochromatic lenses, which bring three wavelengths into focus in the same plane.
#figure(
	image("../figures/1/chromatic-aberration-correction-example-THP-2837582119.jpg",width: 80%),caption: [Chromatic aberration example]
)
#figure(
	image("../figures/1/chromatic-aberration-types-3296485362.png",width: 80%),caption: [Chromatic aberration types]
)
==== Vignetting
Light beams emanating from object points located off-axis are partially blocked by the various apertures (including the individual lens components) positioned inside the lens to limit aberrations. This phenomenon, called *vignetting*, causes the brightness to drop in the image periphery. Vignetting may pose problems to automated image analysis programs, but it is not as important in photography thanks to the human eye’s remarkable insensitivity to smooth brightness gradients. 
#figure(
	image("../figures/1/vignetting.png",width: 80%),caption: [Vignetting effect in a two-lens system. The shaded part of the beam never reaches the second lens. Additional apertures and stops in a lens further contribute to vignetting.]
)
#figure(
	image("../figures/1/vignetting.jpg",width: 80%),caption: [Example of vignetting in a photograph. The corners of the image are darker than the center.]
)
