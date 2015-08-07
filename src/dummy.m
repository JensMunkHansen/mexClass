%> @mainpage Beamformation Toolbox III
%> @author Jens Munk Hansen
%> @date 2011
%>
%> $Id: dummy.m,v 1.21 2011-11-08 14:03:54 jmh Exp $
%>
%> @section section_toc Table of contents
%> <ul>
%>   <li> @ref section_intro
%>   <li> @ref section_beamformation
%>   <li> @ref section_scanlines
%>   <li> @ref section_tof
%>   <ul>
%>     <li> @ref section_unfocused
%>     <li> @ref section_focused
%>     <li> @ref section_fixedfocus
%>     <li> @ref section_ppwave
%>   </ul>
%>   <li> @ref section_apodization
%>   <ul>
%>     <li> @ref section_parapodization
%>     <li> @ref section_dynamicapodization
%>     <li> @ref section_fixedwidthapodization
%>     <li> @ref section_transmitapodization
%>   </ul>
%>   <li> @ref section_examples
%>   <ul>
%>     <li> @ref section_drf
%>     <li> @ref section_sasb
%>   </ul>
%>   <li> @ref section_notclasses
%> </ul>
%>
%> @section section_intro Introduction
%>
%> Focusing and apodization are an essential part of signal
%> processing in ultrasound imaging. Although the fundamental
%> principles are simple, the dramatic increase in computational power
%> of CPUs, GPUs, and FPGAs motivates the development of software based
%> beamformers, which further improves image quality (and the accuracy
%> of velocity estimation). For developing new imaging methods, it is
%> important to establish proof-of-concept before using resources on
%> real-time implementations. With this in mind, an effective and
%> versatile Matlab toolbox written in C++ has been developed to assist
%> in developing new beam formation strategies. It is a general 3D
%> implementation capable of handling a multitude of focusing methods,
%> interpolation schemes, and parametric and dynamic
%> apodization. Despite being flexible, it is capable of exploiting
%> parallelization on a single computer, on a cluster, or on both. On a
%> single computer, it mimics the parallization in a scanner containing
%> multiple beam formers. The focusing is determined using the
%> positions of the transducer elements, presence of virtual sources,
%> and the focus points. For interpolation, a number of interpolation
%> schemes can be chosen, e.g. linear, polynomial, or cubic
%> splines. Apodization can be specified by a number of window functions
%> of fixed size applied on the individual elements as a function of
%> distance to a reference point, or it can be dynamic with an
%> expanding or contracting aperture to obtain a constant F-number, or
%> both. On a standard PC with an Intel Quad-Core Xeon E5520 processor
%> running at 2.26 GHz, the toolbox can beamform 300.000 points using
%> 700.000 data samples in 3 seconds using a transducer
%> with 192 elements, dynamic apodization in transmit and receive, and
%> cubic splines for interpolation. This is 19 times faster than our
%> previous toolbox.
%> 
%> @section section_beamformation Beamformation
%> Beamformation without apodization is all about delays computation for a
%> group of signals exploiting that the sum of these signal can be either
%> constructive or destructive. In medical ultrasound imaging, this is
%> done for both the transmitted and the received field. The type of
%> beamformation varies with the geometry of the transducer and the
%> position of the focal points.
%>
%> For the transmitted field, appropriate delays and possibly an
%> apodization are applied to the transducer elements to construct a
%> number of signals, which sum up constructively at a single focal
%> point. Receive beamformation is similar in the sense that appropriate
%> delays are applied to the signals received from the individual
%> transducer elements and then a weighted sum is performed. Contrary to
%> transmit focusing, when receiving, one can apply a number of delays
%> corresponding to an equal number of focus points. In addition, an
%> apodization can be applied to even out the resolution over a range of
%> depths.
%>
%> To calculate the delays, we need to compute the time-of-flight for
%>the sound propagating from a transmit origin, to the focal points,
%>and back to the receiving elements and convert this time to a sample
%>index. To do the latter, we need to know the sampling frequency and 
%> the speed of sound. The two parameters are set using the @ref 
%> bft3_system class.
%>@code
%>% Setting speed-of-sound and sampling frequency
%>fs = 70e6;
%>c = 1540;
%>globals = bft3_system('c', c,'fs' ,fs);
%>@endcode
%>
%> @section section_scanlines Setting up scan-lines
%> 
%> An image is considered as consisting of a number of
%> scan-lines. The scan-lines are constructed using an origin, a
%> direction, and a length. The scan-lines are constructed using the @ref bft3_line class.
%> @par Example
%> @code
%> single_line = bft3_line([0 0 0], [0 0 1], c/fs, 40/1000);
%> @endcode
%>
%> @section section_tof Time-of-flight calculation
%>
%> As just stated, we need to compute the time-of-flight for the sound
%> propagating from the transmit origin, to the
%> focal points and return to the receiving
%> elements. Using the toolbox the transmit origin is set using the
%> @ref bft3_aperture::center_focus property on the transmit aperture,
%> which is constructed using the constructor @ref
%> bft3_aperture::bft3_aperture.
%> @par Example
%>@code
%>f0 = 5e6; lambda = c/f0;
%>pitch = lambda;
%>xmt_aperture = bft3_aperture('type','linear_array','pitch',pitch,...
%>                             'n_elements',64);
%>@endcode
%> - Note the positions of the transmit aperture are only used for transmit apodization, see @ref section_apodization for details
%>
%> @subsection section_unfocused Unfocused beams
%>The task of computing the
%>time-of-flight can be split into
%> computing a transmit and a receive time corresponding to a transmit
%> and a receive focus, \f$t_{\mathrm{\scriptscriptstyle{TOF}}} = t_{\mathrm{\scriptscriptstyle{TOF}}_{\mathrm{xmt}}}+t_{\mathrm{\scriptscriptstyle{TOF}}_{\mathrm{rcv}}}\f$.  Assuming the
%>speed of sound, \f$c\f$ is constant, we get
%>\f{eqnarray}{\label{eq:q}
%>  t_{\mathrm{\scriptscriptstyle{TOF}}}&=&
%>  t_{\mathrm{\scriptscriptstyle{TOF}}_{\mathrm{xmt}}} +
%>  t_{\mathrm{\scriptscriptstyle{TOF}}_{\mathrm{rcv}}}\nonumber \\
%>  &=&\frac{\left|\vec{r}_{\mathrm{fp}}-\vec{r}_{\mathrm{xmt}}\right|+\left|\vec{r}_{\mathrm{rcv}}-\vec{r}_{\mathrm{fp}}\right|}{c}.
%>\f}
%>If secondary scattering is neglected, the receive path is a straight
%>line and the receive time is uniquely determined. The transmit path
%>however is not well defined, since the emitted pressure wave does not
%>emanate from a point source
%> \f$\vec{r}_{\mathrm{\scriptscriptstyle{fp}}_{\mathrm{xmt}}}\f$ as
%>indicated in Fig. 1 but rather from a complicated pattern resulting from numerous waves emitted from different elements at different times obeying Huygens' principle. For an unfocused beam though, (1) is close to correct. To consider an unfocused beam, the @ref bft3_aperture::focus property must be empty on the transmit aperture.
%>@code
%>xmt_aperture.focus = [];
%>@endcode
%> @subsection section_focused Focused beams
%> For a focused beam, the transmit time can be approximated by considering the transmit focal point \f$\vec{r}_{\mathrm{\scriptscriptstyle{fp}}_{\mathrm{xmt}}}\f$ as a virtual point source emitting a spherical wave. By using this approximation, the \f$t_{\mathrm{\scriptscriptstyle{TOF}}}\f$ becomes
%> \f{equation}{t_{\mathrm{\scriptscriptstyle{TOF}}}=\frac{\left|\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}}-\vec{r}_{\mathrm{xmt}}\right|\pm \left|\vec{r}_{\mathrm{fp}}-\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}}\right|+\left|\vec{r}_{\mathrm{rcv}}-\vec{r}_{\mathrm{fp}}\right|}{c},\f}
%>where the \f$\pm \f$ in (2) refers to whether the focal point is
%>above or below a plane orthogonal to the center line of the beam. To introduce a virtual source \f$\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}}\f$, the @ref bft3_aperture::focus property on the transmit aperture should be set to the given position.
%>@code
%>xmt_aperture.focus = [0 0 40/1000];
%>@endcode
%>
%> \image html focused_below.png "Fig. 1a: Focus point below plane" \image html focused_above.png "Fig. 1b: Focus point above plane" 
%> \image latex focused_below.eps "Focus point below plane" width=7cm \image latex focused_above.eps "Focus point above plane" width=7cm
%>
%> For a beam perpendicular to the aperture, the plane deciding the
%> sign in (2) is parallel to the aperture.
%>  
%> @subsection section_fixedfocus Fixed focusing
%> To consider fixed receive focusing, a virtual source can be introduced for the receive aperture
%>@code
%>rcv_aperture.focus = [0 0 40/1000];
%>@endcode
%> and the \f$t_{\mathrm{\scriptscriptstyle{TOF}}}\f$ becomes
%> \f{equation}{t_{\mathrm{\scriptscriptstyle{TOF}}}=\frac{\left|\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}}-\vec{r}_{\mathrm{xmt}}\right|\pm \left|\vec{r}_{\mathrm{fp}}-\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}}\right|+\left|\vec{r}_{\mathrm{fp}_{\mathrm{rcv}}}-\vec{r}_{\mathrm{rcv}}\right|\pm \left|\vec{r}_{\mathrm{fp}}-\vec{r}_{\mathrm{fp}_{\mathrm{rcv}}}\right|}{c},\f}
%> For synthetic aperture sequential beamformation (SASB), the
%> first stage is a fixed focus beamformation stage.
%> @subsection section_ppwave Plane-wave focusing
%> For plane-wave beamformation, the
%> \f$t_{\mathrm{\scriptscriptstyle{TOF}}_{\mathrm{xmt}}}\f$ is
%> computed using the distance to the plane of emission and the
%> \f$t_{\mathrm{\scriptscriptstyle{TOF}}}\f$ becomes
%> \f{equation}{t_{\mathrm{\scriptscriptstyle{TOF}}}=\frac{\left|\left(\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}}-\vec{r}_{\mathrm{xmt}}\right)\cdot \vec{n}\right| + \left|\vec{r}_{\mathrm{rcv}}-\vec{r}_{\mathrm{fp}}\right|}{c},\f}
%> In the
%> toolbox, this plane is defined as the plane containing the
%> transmit origin \f$\vec{r}_{\mathrm{xmt}}\f$ set using the
%> @ref bft3_aperture::center_focus property on the transmit
%> aperture and perpendicular to a normal vector \f$\vec{n}\f$defined using
%> Euler angles following the Z-X'-Z'' convention (See wikipedia <a
%> href="http://en.wikipedia.org/wiki/Euler_angles">Euler angles</a>). The normal
%> vector is set using the @ref bft3_aperture::orientation
%> property on the transmit aperture.
%> \image html plane_wave.png "Fig. 2: Plane-wave focusing"
%> \image latex plane_wave.eps "Plane-wave focusing" width=10cm
%>
%> The result of beamforming a single point is a weighted sum of
%> contributions for each transmit-receive channel pair. For imaging,
%> we are interested in the absolute values and typically, we would
%> either beamform complex data and compute the absolute or beamform a
%> scan line of points and compute the envelope. For velocity estimation,
%> we are interested in the phase and would therefore beamform densely
%> sampled lines and possibly also in multiple directions, the latter for
%> directional velocity estimation.
%>
%> @section section_apodization Apodization
%>  
%> In addition to focusing, beamformation also includes apodization,
%> i.e. the possibility for tapering of the individual receive
%> channels and also a possible overall scaling for an emission used
%> for synthetic aperture imaging. If we include apodization, a
%> beamformed image point at position \f$\vec{r}_{\mathrm{fp}}\f$ is
%> computed according to
%> \f{equation}{I\left(\vec{r}_{\mathrm{fp}}\right)=\sum_{\mathrm{xmt}=1}^{N_{\mathrm{xmt}}}\mathcal{A}_{\mathrm{xmt}}\left(\vec{r}_{\mathrm{fp}}\right)\sum_{\mathrm{rcv}=1}^{N_{\mathrm{rcv}}}\mathcal{A}_{\mathrm{rcv}}\left(\vec{r}_{\mathrm{fp}}\right)s_{\mathrm{xmt},\mathrm{rcv}}\left(t_{\mathrm{\scriptscriptstyle{TOF}}}\left(\vec{r}_{\mathrm{xmt}},\vec{r}_{\mathrm{fp}_{\mathrm{xmt}}},\vec{r}_{\mathrm{fp}},\vec{r}_{\mathrm{rcv}}\right) \right)\f}
%> where \f$N_{\mathrm{rcv}}\f$ is the number of receiving elements, \f$\mathcal{A}(\vec{r}_{\mathrm{fp}})\f$ is the apodization function in transmit and receive, and \f$s_{\mathrm{xmt},\mathrm{rcv}}(t)\f$ is the interpolated time-domain echo signal received at element \f$\mathrm{xmt}\f$ after the \f$\mathrm{rcv}\f$'th emission. \f$N_{\mathrm{xmt}}\f$ is the number of emissions used to construct the image point, where the origin of the emissions are spatially different, which is used in synthetic transmit aperture imaging. For a conventional B-mode image, \f$N_{\mathrm{xmt}}=1\f$.
%>
%> In the toolbox the @ref bft3_apodization class holds the defining properties of the tapering of
%> the individual receive channels and the information for a possible overall scaling for an
%> emission used for synthetic aperture imaging. An apodization is defined for each scan-line for both the transmitting and receiving aperture. The @ref bft3_apodization class support two ways of tapering and the resulting apodization
%> is the product thereof.
%>
%> @subsection section_parapodization Parametric apodization
%>  It can be defined completely in the sense that
%> the user can define a number of windows (@ref bft3_apodization::values) to be applied for a number of
%> range intervals, the range being defined as the distance (@ref bft3_apodization::distances) from an
%> apodization reference point (@ref bft3_apodization::ref) to the focus point. This makes it possible
%> to a apply simple apodization or extraordinary apodization functions. Parametric apodization is enabled when the @ref bft3_apodization::parametric property is enabled (default = true).
%> @par Example
%> @code
%> % Construct apodization object to be used for a single line
%> rcv_apodization = bft3_apodization(rcv_aperture, [0 0 0], 0, ones(64,1));
%> @endcode
%>
%> @subsection section_dynamicapodization Dynamic apodization
%>
%> The second possibility is
%> dynamic apodization with an expanding and contracting aperture defined using an F-number (@ref bft3_apodization::f), an analytical window function (@ref bft3_apodization::window), and the apodization reference (@ref bft3_apodization::ref). The width of an active sub-aperture for a given focus point is then computed using the distance to the apodization reference and the F-number.  If the active sub-aperture extends outside the physical aperture, then only an inner fraction of the apodization window are applied as illustrated in Fig. 3.
%>
%> Apodization object are constructed using the constructor @ref bft3_apodization::bft3_apodization by specifying an aperture, a reference point, a number of distances, and a set of apodization @ref bft3_apodization::values. See @ref bft3_apodization for further details.
%>
%> @par Example
%> @code
%> % Disable parametric and enable dynamic apodization
%> rcv_apodization.parametric = false;
%> rcv_apodization.dynamic = true;
%> rcv_apodization.f = 1.2;
%> @endcode
%> It is important to construct two independent apodization objects for each line if multi-threading is desired. The number of execution threads is set using the @ref bft3_image::nthreads property of the @ref bft3_image class.
%>
%> \image html sa_apodization.png "Fig. 3: Apodization calculation"
%> \image latex sa_apodization.eps "Apodization calculation" width=10cm
%>
%> In Fig. 3, the wave propagation paths for
%> transmit-receive element pairs for two different focal points are
%> shown. In addition, an apodization profile is calculated corresponding
%> to a common F-number for the two depths (The F-numbers used
%>  for transmit and receive can of course also be different as well as
%>  the window functions). The apodization values for the elements is
%> determined by the orthogonal distance from their positions to the
%> apodization line as indicated by the intersections between the dashed
%> lines and the two apodization profiles. Note that for the focal point
%> \f$\vec{r}_{\mathrm{fp}_{2}}\f$, we are running out of aperture and an
%> edge-wave will most likely appear in the image. A possible way to deal with such edge-waves is to use enable both dynamic and parametric apodization and the resulting apodization will be the product.
%>
%> @subsection section_fixedwidthapodization Fixed width apodization
%>
%> Fixed-width apodization is only available for images constructed using the @ref bft3_sampled_image class. It is an experimental feature and only supported for apertures constructed with the @ref bft3_aperture::type qualifier equal to 'linear_array'. The apodization is computed with a width corresponding to @ref bft3_apodization::n_active_elements and arranged symmetrically around a line from @ref bft3_apodization::ref to the focus point. The individual elements are then tapered according to their orthogonal distance to this line.
%>
%> @subsection section_transmitapodization Transmit apodization
%>
%> Transmit apodization can likewise be parametric or dynamic. For a dynamic apodization, the dynamic width of the sub-aperture is computed using the transmit F-number @ref bft3_apodization::f, the distance from the focus point to the apodization reference @ref bft3_apodization::ref. The apodization is then computed using the distance from the virtual source of the emission to the line from the apodization reference @ref bft3_apodization::ref to the focus point. This is unfortunate for synthetic aperture beamformation using a convex array, since in this case we would like the transmit apodization to be a triangular tappering of a low-resolution image, the triangle centered around the emission. At the moment, an apodization like this can be obtained by putting all transmit apodization references equal to the beginning of the lines and adjusting the orientation property @ref bft3_aperture::orientation of the transmit aperture in between emissions using the angle between the direction of the emission and z-axis. In this way, the apodization is calculated using the distance from the virtual source of the emission (position of an element on the transmit aperture) to the line from the apodization reference @ref bft3_apodization::ref to the focus point rotated according to the orientation @ref bft3_aperture::orientation. By further scaling the transmit F-number @ref bft3_apodization::f by a factor \f$1/\cos{(\theta)}\f$, where \f$\theta\f$ is the angle betwen the direction of the emission and the z-axis, the correct apodization is obtained. In the future, the transmit apodization should be changed such that it is calculated using the distance from a line defining the emission and the focus point. The reader is invited to experiment using a dataset consisting of only one value to get familiar with how transmit apodization works.
%>
%> For the moment the position of the virtual sources are specified as the positions of transducer element on the transmit aperture and the position used for an emission is specified when calling the @ref bft3_image::beamform function. The reason why we don't use the @ref bft3_aperture::center_focus is that for an unfocused emission, we start sampling after all elements have fired and at this time the wave-front is on the surface of the aperture, whereas the virtual source of the emission is somewhere behind the transducer surface.
%> @par Example
%> @code
%> % Beamformation of single-line image
%> img = bft3_image(xmt_aperture, rcv_aperture, xmt_apodization, rcv_apodization, single_line);
%> % Dynamic transmit apodization (if enabled) uses the virtual origin located at the 32'th transducer element
%> rf_line = img.beamform(rf_data, tstart, uint32(32));
%> @endcode
%> 
%> @section section_examples Examples
%> A number of examples exist in the examples directory.
%> @subsection section_drf Dynamic receive focusing
%> An example for simulating data with Field II and beamforming an
%> image using dynamic receive focusing is given in <a
%>href="../../examples/psf_8804p.m" type="text/plain">psf_8804p.m</a>
%> @subsection section_sasb Synthetic aperture sequential beamformation (SASB)
%> An example for simulating data with Field II and beamforming an
%> image using SASB is given in <a
%> href="../../examples/psf_sasb_8804.m" type="text/plain">
%> psf_sasb_8804.m</a>
%>
%> @section section_notclasses A note on Matlab classes
%>
%> All functions with the following prototype
%>
%>      <table class="memname">
%>        <tr>
%>          <td class="memname">function set <a class="el" href="classbft3__aperture.html#ae95ef5465358a2cb52ad21c42952c745">some_class::some_property</a> </td>
%>          <td>(</td>
%>          <td class="paramtype">in&nbsp;</td>
%>          <td class="paramname"> <em>obj</em>, </td>
%>        </tr>
%>        <tr>
%>          <td class="paramkey"></td>
%>          <td></td>
%>          <td class="paramtype">in&nbsp;</td>
%>          <td class="paramname"> <em>data</em></td><td>&nbsp;</td>
%>        </tr>
%>        <tr>
%>          <td></td>
%>          <td>)</td>
%>          <td></td><td></td><td></td>
%>        </tr>
%>      </table>
%>
%> can be invoked using the assignment operator
%>@code
%>some_object.some_property = data;
%>@endcode
%> Similarly all functions with the prototype
%>
%>        <table class="memname">
%>        <tr>
%>          <td class="memname">function get <a class="el" href="classbft3__aperture.html#ae95ef5465358a2cb52ad21c42952c745">some_class::some_property</a> </td>
%>          <td>(</td>
%>          <td class="paramtype">in&nbsp;</td>
%>          <td class="paramname"> <em>obj</em></td>
%>          <td>&nbsp;)&nbsp;</td>
%>          <td></td>
%>        </tr>
%>      </table>
%> can be invoked using left value assignment
%>@code
%>variable_name = some_object.some_property;
%>@endcode
  
