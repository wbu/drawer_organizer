// global design parameters
height = 60;
width_bottom = 13;
width_top = 5;

border_top_bottom_distance = [0, 8];

gap = 0.15;
gap_top = 1;  // overhang needs bigger tolerances

$fa = 5;
$fs = 0.1;

// derived variables
radius_bottom = width_bottom/2;
radius_top = width_top/2;
height_linear = height-radius_top;
connector_length = 2*max(width_top, width_bottom);

//showcase();
example();


module showcase(space=40) {
    module lineup(space) {
       for (i = [0 : 1 : $children-1])
         translate([ space*i, 0, 0 ]) children(i);
    }
    lineup(space) {
        divider_bend(distance=-20);
        divider_bend();
        divider_lowered();
        divider();
        connector_zero();
        connector_straight();
        connector_t();
        connector_x();
        connector_corner(round=true);
        connector_corner(round=false);
        border_straight_x();
        border_straight_y();
        border_corner();
        group();
        group();
        border_corner_flipped();
    }
}

module example() {
    border_corner([30,150]);
    translate([2*(30+connector_length), 0])
        rotate([0, 0, 270])
            border_straight(30);
    translate([3*(30+connector_length), 0])
        rotate([0, 0, 270])
            border_straight(30);
    translate([4*(30+connector_length), 0])
        rotate([0, 0, 270])
            border_straight(30);
    translate([5*(30+connector_length), 0])
        rotate([0, 0, 270])
            border_straight(30);
    translate([6*(30+connector_length), 0])
        border_corner_flipped([30,150]);
    translate([0, -(150+30+2*connector_length)])
        scale([1, -1, 1])
            border_corner([3*30+2*connector_length, 30]);
    translate([6*(30+connector_length), -(150+30+2*connector_length)])
        scale([1, -1, 1])
            border_corner_flipped([3*30+2*connector_length, 30]);

    translate([1*(30+connector_length), -0.5*connector_length])
        divider(100);
    translate([2*(30+connector_length), -0.5*connector_length])
        divider(100);
    translate([3*(30+connector_length), -0.5*connector_length])
        divider(100);
    translate([4*(30+connector_length), -0.5*connector_length])
        divider(150);
    translate([5*(30+connector_length), -0.5*connector_length])
        divider(150);

    translate([1*(30+connector_length), -(100 + connector_length)])
        connector_corner();
    translate([2*(30+connector_length), -(100 + connector_length)])
        rotate([0, 0, 270])
            connector_t();
    translate([3*(30+connector_length), -(100 + connector_length)])
        connector_t();

    translate([1*(30+connector_length)+0.5*connector_length, -(100 + connector_length)])
        rotate([0, 0, 90])
            divider(30);
    translate([2*(30+connector_length)+0.5*connector_length, -(100 + connector_length)])
        rotate([0, 0, 90])
            divider(30);
    translate([0.5*connector_length, -(150 + connector_length)])
        rotate([0, 0, 90])
            divider(3*30+2*connector_length);
    translate([3*(30+connector_length)+0.5*connector_length, -(150 + connector_length)])
        rotate([0, 0, 90])
            divider(30);
    translate([4*(30+connector_length)+0.5*connector_length, -(150 + connector_length)])
        rotate([0, 0, 90])
            divider(30);
    translate([5*(30+connector_length)+0.5*connector_length, -(150 + connector_length)])
        rotate([0, 0, 90])
            divider(30);
    translate([3*(30+connector_length), -(100 + 1.5*connector_length)])
        divider(50-connector_length);
    translate([3*(30+connector_length), -(150 + 1.5*connector_length)])
        divider(30);

    translate([3*(30+connector_length), -(150 + connector_length)])
        connector_x();
    translate([4*(30+connector_length), -(150 + connector_length)])
        rotate([0, 0, 270])
            connector_t();
    translate([5*(30+connector_length), -(150 + connector_length)])
        rotate([0, 0, 270])
            connector_t();
}

module profile_shape() {
    polygon([
        [-radius_bottom, 0],
        [radius_bottom, 0],
        [radius_top, height_linear],
        [-radius_top, height_linear]
    ]);
    translate([0, height_linear])
        circle(r=radius_top);
}

module profile(length=150) {
    rotate([90,0,0])
        linear_extrude(height=length)
            profile_shape();
}

module profile_round(radius, angle=90) {
    translate([-radius,0]) {
        rotate_extrude(angle=angle) {
            translate([radius,0])
                profile_shape();
        }
    }
}

module profile_corner(round=false) {
    // bottom part
    difference() {
        if (round) {
            intersection() {
                translate([-0.5*connector_length, -0.5*connector_length])
                    cube([connector_length, connector_length, height_linear]);
                translate([0.5*connector_length, 0.5*connector_length]) {
                    rotate_extrude() {
                        polygon([
                            [0, 0],
                            [0.5*connector_length+radius_bottom, 0],
                            [0.5*connector_length+radius_top, height_linear],
                            [0, height_linear]
                        ]);
                    }
                }
            }
        } else {
            cube([0.5*connector_length, 0.5*connector_length, height_linear]);
        }
        translate([0.5*connector_length, 0.5*connector_length]) {
            rotate_extrude() {
                polygon([
                    [0, 0],
                    [0.5*connector_length-radius_bottom, 0],
                    [0.5*connector_length-radius_top, height_linear],
                    [0, height_linear]
                ]);
            }
        }
    }
    // top round part
    intersection() {
        translate([0, 0, height_linear]) {
            if (round) {
                translate([-0.5*connector_length, -0.5*connector_length])
                    cube([connector_length, connector_length, radius_top]);
            } else {
                cube([0.5*connector_length, 0.5*connector_length, radius_top]);
            }
        }
        translate([0.5*connector_length, 0.5*connector_length]) {
            rotate_extrude() {
                translate([0.5*connector_length, height_linear])
                    circle(r=radius_top);
            }
        }
    }
    // top flat part
    if (!round) {
        difference() {
            translate([0, 0, height_linear])
                cube([0.5*connector_length, 0.5*connector_length, radius_top]);
            translate([0.5*connector_length, 0.5*connector_length, height_linear])
                cylinder(h=radius_top, r=0.5*connector_length);
        }
    }
}


module fitting(male=true) {
    // shrink male piece a little bit
    gap = male ? gap : 0;
    gap_top = male ? gap_top : 0;
    connector_length = radius_bottom;
    // For crazy people, that choose width_top > width_bottom. Otherwise pieces
    // cannot be sticked together. Such a design actually looks quite nice ;)
    radius_top = radius_top <= radius_bottom ? radius_top : radius_bottom;
    radius_top_corrected = radius_top+(radius_bottom-radius_top)*gap_top/height_linear;
    linear_extrude(height=height_linear-gap_top, scale=radius_top_corrected/radius_bottom) {
        polygon([
            [-0.3*radius_bottom+gap, 0],
            [0.3*radius_bottom-gap, 0],
            [0.5*radius_bottom-gap, connector_length],
            [-0.5*radius_bottom+gap, connector_length]
        ]);
        translate([0,connector_length]) {
            circle(r=0.6*radius_bottom-gap);
            // add "air channel" for female piece
            if (!male)
                translate([-0.1*radius_bottom,0])
                    square([0.2*radius_bottom, radius_bottom]);
        }
    }
}

module divider(length=100) {
    difference() {
        profile(length);
        rotate([0,0,180])
            fitting(male=false);
        translate([0,-length])
            fitting(male=false);
    }
}

module divider_lowered(length=100, lower=0.5, radius1=40, radius2=8) {
    assert(radius1 >= radius_top, "divider_lowered: radius1 must be greater than width_top/2!");
    assert(radius2 >= radius_top, "divider_lowered: radius2 must be greater than width_top/2!");

    height_lower = height_linear*lower;
    angle1 = height_lower > 2*radius1 ? 90 : acos(1-0.5*height_lower/radius1);
    length_round1 = sin(angle1)*radius1;
    height_round1 = (1-cos(angle1))*radius1;
    height_ortho1 = height_lower > 2*radius1 ? height_lower-2*radius1 : 0;
    angle2 = height_lower > 2*radius2 ? 90 : acos(1-0.5*height_lower/radius2);
    length_round2 = sin(angle2)*radius2;
    height_round2 = (1-cos(angle2))*radius2;
    height_ortho2 = height_lower > 2*radius2 ? height_lower-2*radius2 : 0;
    length_ortho = length - 2*(length_round1 + length_round2);
    assert(length_ortho >= 0, "divider_lowered: radius1+radius2 too big or length too small");

    module round_edge(radius, angle, length_round, height_round, height_ortho) {
        translate([0, 0, height_linear-radius])
            rotate([0,-90,180])
                rotate_extrude(angle=angle)
                    translate([radius, 0])
                        circle(r=radius_top);
        if (height_ortho > 0) {
            translate([0, -length_round, height-height_lower+height_round-radius_top])
                linear_extrude(height_ortho)
                    circle(r=radius_top);
        }
        translate([0, -2*length_round, height-height_lower+radius-radius_top])
            rotate([0,90,0])
                rotate_extrude(angle=angle)
                    translate([radius, 0])
                        circle(r=radius_top);
    }

    module spread() {
        angle = asin((radius_bottom - radius_top) / height_linear);
        z_correction = 1/cos(angle);
        translate([0, 0, height_linear])
            scale([1, 1, z_correction])
                rotate([0, angle, 0])
                    translate([0, 0, -height_linear])
                        children();
        translate([0, 0, height_linear])
            scale([1, 1, z_correction])
                rotate([0, -angle, 0])
                    translate([0, 0, -height_linear])
                        children();
    }

    module flat_profile(radius, length_round, height_round, height_ortho) {
        intersection() {
            translate([0, height-height_round-radius_top])
                square([length_round, height_round]);
            translate([0, height-radius-radius_top])
                circle(r=radius);
        }
        difference() {
            translate([length_round, height-height_lower-radius_top])
                square([length_round, height_round]);
            translate([2*length_round, height-height_lower-radius_top+radius]) {
                circle(r=radius);
            }
        }
        translate([0, height-height_lower-radius_top])
            square([length_round, height_round+height_ortho]);
    }

    module flat_cap(top=true) {
        max_radius = max(radius_top, radius_bottom);
        rotate([90,0,270]) {
            translate([0,0,-max_radius]) {
                linear_extrude(height=2*max_radius) {
                    offset(r=top?radius_top:0) {
                        union() {
                            square([length, height-height_lower-radius_top]);
                            flat_profile(radius1, length_round1, height_round1, height_ortho1);
                            translate([length, 0])
                                scale([-1, 1])
                                    flat_profile(radius2, length_round2, height_round2, height_ortho2);
                        }
                    }
                }
            }
        }
    }

    difference() {
        union() {
            // top round edge
            spread() {
                // radius1 round edge
                round_edge(radius1, angle1, length_round1, height_round1, height_ortho1);
                // center round edge
                if (length_ortho > 0) {
                    translate([0, -2*length_round1, height-height_lower-radius_top])
                        rotate([90, 0, 0])
                            linear_extrude(length_ortho)
                                circle(r=radius_top);
                }
                // radius2 round edge
                translate([0, -length, 0])
                    rotate([0,0,180])
                        round_edge(radius2, angle2, length_round2, height_round2, height_ortho2);
            }

            // flat top
            intersection() {
                flat_cap(top=true);
                rotate([90, 0, 0]) {
                    linear_extrude(height=length) {
                        polygon([
                            [-max(0,(radius_bottom-radius_top)), 0],
                            [max(0,(radius_bottom-radius_top)), 0],
                            [0, height]
                        ]);
                    }
                }
            }

            // body
            intersection() {
                profile(length);
                flat_cap(top=false);
            }
        }
        rotate([0,0,180])
            fitting(male=false);
        translate([0,-length])
            fitting(male=false);
    }
}

module divider_bend(length=100, distance=20, radius=50) {
    // more helpful error message for rotate_extrude() error in profile_round()
    assert(radius >= radius_bottom, str("divider_bend: radius (", radius, ") too small, must be >= ", radius_bottom));
    angle = (abs(distance) >= 2*radius ? 90 : acos(1-0.5*abs(distance)/radius))*sign(distance);
    length_ortho = abs(distance) >= 2*radius ? abs(distance)-2*radius : 0;
    length_round = abs(distance) >= 2*radius ? radius : abs(sin(angle))*radius;
    length_start = 0.5*(length-2*length_round);
    assert(length >= 2*length_round, "divider_bend: length too short or radius too big");
    difference() {
        union() {
            if (length_start > 0) {
                profile(length_start);
                translate([distance,length_start-length])
                    profile(length_start);
            }
            translate([0,-length_start])
                rotate([0,0,180])
                    profile_round(radius=radius*sign(angle), angle=angle);
            translate([distance, length_start-length])
                profile_round(radius=radius*sign(angle), angle=angle);
            if (length_ortho > 0) {
                translate([angle>0?radius:-length_ortho-radius,-0.5*length])
                    rotate([0,0,90])
                        profile(length_ortho);
            }
        }
        rotate([0,0,180])
            fitting(male=false);
        translate([distance,-length])
            fitting(male=false);
    }
}

module connector_zero() {
    union() {
        fitting(male=true);
        rotate([0,0,180])
            fitting(male=true);
    }
}

module connector_straight() {
    translate([0,0.5*connector_length,0]) {
        union() {
            profile(connector_length);
            fitting(male=true);
            translate([0,-connector_length,0])
                rotate([0,0,180])
                    fitting(male=true);
        }
    }
}

module connector_x() {
    union() {
        for (r=[0, 90, 180, 270]) {
            rotate([0,0,r]) {
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
                profile_corner();
            }
        }
    }
}

module connector_t() {
    union() {
        for (r=[0, 90, 180]) {
            rotate([0,0,r])
                translate([0,0.5*connector_length,0])
                    fitting(male=true);
        }
        for (r=[90, 180]) {
            rotate([0,0,r])
                profile_corner();
        }
        translate([0,0.5*connector_length,0])
            profile(connector_length);
    }
}

module connector_corner(round=true) {
    union() {
        profile_corner(round=round);
        for (r=[0,270]) {
            rotate([0,0,r]) {
                translate([0,0.5*connector_length,0]) {
                    fitting(male=true);
                    if (!round)
                        profile(length=0.5*connector_length);
                }
            }
        }
        if (!round) {
            rotate([0,0,180]) {
                rotate_extrude(angle=90) {
                    intersection() {
                        profile_shape();
                        square([max(radius_bottom, radius_top), height]);
                    }
                }
            }
        }
    }
}

module add_distance_xy(length, distance) {
    max_bottom_distance = radius_top <= radius_bottom ? radius_bottom - radius_top : 0;
    bottom_distance = [min(max_bottom_distance, distance[0]),
                       min(max_bottom_distance, distance[1])];
    top_distance = [distance[0] - bottom_distance[0],
                    distance[1] - bottom_distance[1]];
    difference() {
        union() {
            children();
            rotate([90, 0, 0]) {
                translate([0, 0, -top_distance[0]]) {
                    linear_extrude(height=length[1]+connector_length+top_distance[0]) {
                        polygon([
                            [bottom_distance[1], 0],
                            [0, height],
                            [-top_distance[1], height],
                        ]);
                    }
                }
            }
            rotate([90, 0, 90]) {
                translate([0, 0, -top_distance[1]]) {
                    linear_extrude(height=length[0]+connector_length+top_distance[1]) {
                        polygon([
                            [-bottom_distance[0], 0],
                            [0, height],
                            [top_distance[0], height],
                        ]);
                    }
                }
            }
        }
        rotate([90, 0, 0]) {
            translate([0, 0, -top_distance[0]]) {
                linear_extrude(height=length[1]+connector_length+top_distance[0]) {
                    polygon([
                        [bottom_distance[1], 0],
                        [-top_distance[1], height],
                        [-top_distance[1], 0]
                    ]);
                }
            }
        }
        rotate([90, 0, 90]) {
            translate([0, 0, -top_distance[1]]) {
                linear_extrude(height=length[0]+connector_length+top_distance[1]) {
                    polygon([
                        [-bottom_distance[0], 0],
                        [top_distance[0], height],
                        [top_distance[0], 0]
                    ]);
                }
            }
        }
    }
}

module border_straight(length=100, distance=0) {
    add_distance_xy([0, length], [0, distance]) {
        intersection() {
            union() {
                translate([0, -0.5*connector_length, 0])
                    profile(length);

                rotate([0, 0, 270])
                    profile_corner();

                translate([0, -(length+connector_length), 0])
                    profile_corner();

                translate([0.5*connector_length, 0, 0])
                    rotate([0, 0, 270])
                        fitting(male=true);
                translate([0.5*connector_length, -(length+connector_length), 0])
                    rotate([0, 0, 270])
                        fitting(male=true);
            }
            translate([0, -(length+connector_length), 0])
                cube([2*connector_length, length+connector_length, height]);
        }
    }
}

module border_straight_x(width=100) {
    border_straight(length=width, distance=border_top_bottom_distance[0]);
}

module border_straight_y(depth=100) {
    border_straight(length=depth, distance=border_top_bottom_distance[1]);
}

module border_corner(length=[30, 100], distance=border_top_bottom_distance) {
    add_distance_xy(length, distance) {
        intersection() {
            union() {
                translate([0, -0.5*connector_length, 0])
                    profile(length[1]);
                translate([0.5*connector_length, 0, 0])
                    rotate([0, 0, 90])
                        profile(length[0]);

                rotate([0, 0, 270])
                    profile_corner();
                translate([0, -(length[1]+connector_length)])
                    profile_corner();
                translate([length[0]+connector_length, 0, 0])
                    rotate([0, 0, 180])
                        profile_corner();

                translate([connector_length+length[0], -0.5*connector_length, 0])
                    rotate([0, 0, 180])
                        fitting(male=true);
                translate([0.5*connector_length, -(length[1]+connector_length), 0])
                    rotate([0, 0, 270])
                        fitting(male=true);
            }
            translate([0, -(length[1]+connector_length), 0])
                cube([length[0]+connector_length, length[1]+connector_length, height]);
        }
    }
}

module border_corner_flipped(length=[30, 100], distance=border_top_bottom_distance) {
    scale([-1, 1, 1])
        border_corner(length=length, distance=distance);
}
