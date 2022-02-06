include <bezier.scad>;

$fn=50;
solid_thick = 10;

length_min = 348;
length_mid = 351;
length_max = 355;

length_min_offset = length_max - length_min;
length_mid_offset = length_max - length_mid;
width = 235;
handle_side_min = 50;
handle_side_max = 60;
depth = 45; 
fix = 0.01;
gap = 0.6;



module reduce(padding) {
    
    difference() {
        children();
        minkowski() {        
            difference() {
                minkowski() {
                    children();
                    cylinder(r=padding, height=padding, center=true);
                };
                children();
            };
            cylinder(r=padding, height=fix, center=true);
        }
    }
}

module reduce_y(padding) {
    difference() {
        children();
        minkowski() {        
            difference() {
                minkowski() {
                    children();
                    cylinder(r=padding, height=padding, center=true);
                };
                children();
            };
            cube([fix, padding*2, fix], center=true);
        }
    }
}

module solid() {
    translate([-solid_thick,-solid_thick, -solid_thick])
    cube([width+solid_thick*2,length_max+solid_thick*2, depth + solid_thick]);
}

module void() {
    translate([20, length_min_offset,0])
    cube([width-40, length_min-20, depth+fix]);
  
    translate([0, length_min_offset+20,0])
    cube([width, length_min-20, depth+fix]);
      
}


p0 = [handle_side_min,0];
p1 = [handle_side_min+5,0];
p2 = [handle_side_max-5,length_min_offset];
p3 = [handle_side_max,length_min_offset];


module smooth() {
    linear_extrude(height=depth+10+fix*3)
    polygon(concat(
        cubic_bezier(
            [0,length_mid_offset+1],
            [0,length_mid_offset-1],           
            [handle_side_min-10,0],
            [handle_side_min,0]
        ),
        cubic_bezier(
            [handle_side_min,0],
            [handle_side_min+5,0],
            [handle_side_max-5,length_min_offset],
            [handle_side_max,length_min_offset]    
        ),
        [
            [handle_side_max+10,length_min_offset],
            [handle_side_max+10,length_min_offset+70],
            [0,length_min_offset+70]
        ])
    );
}

module smooth_old() {
    linear_extrude(height=depth+fix)
    polygon(concat([
            [0,length_mid_offset]
        ],
        cubic_bezier(
            [handle_side_min,0],
            [handle_side_min+5,0],
            [handle_side_max-5,length_min_offset],
            [handle_side_max,length_min_offset]    
        ),
        [
            [handle_side_max+10,length_min_offset],
            [handle_side_max+10,length_min_offset+10],
            [0,length_min_offset+10]
        ])
    );
}

module cassetto() {
    difference() {
        solid();
        void();
        smooth();
        translate([width,0,0])
        mirror([1,0,0])
        smooth();
    }
}

    


box_length = 50;
box_width = 50;
box_depth = 50;
box_bottom_thick = 1.6;
box_wall_thick = 1.6;

box_hang_label_width = 30;
box_hang_label_length = 10;
box_hang_label_margin = 2;
box_hang_play = 0.3;
box_hang_eps = 1.5;
box_hang_width = box_hang_label_width+box_hang_label_margin*2-box_hang_eps*2+box_hang_play*2;
box_hang_length = box_hang_label_length+box_hang_label_margin-box_hang_eps+box_hang_play*2;
box_hang_thick = 2;




module box_hang_solid() {
    difference() {
        hull() {
            translate([0,0,-box_hang_thick])
            cube([box_hang_width,box_hang_length,box_hang_thick]);
            translate([0,box_hang_length-fix, -box_hang_thick-box_hang_length])
            cube([box_hang_width,fix,fix]);
        };
        translate([box_hang_width/2,-box_hang_width*0.02,-box_hang_width*0.57])
        sphere(box_hang_width*0.48, $fn=100); 
    }
}

module box_hang_firm() {
    hull() {
        translate([
            box_hang_eps*3,
            box_hang_length-fix,
            0        
        ])
        cube([
            box_hang_width-box_hang_eps*6,
            fix,
            fix    
        ]);
        
        translate([
            box_hang_eps*2,
            box_hang_length-box_hang_eps,
            -box_hang_eps    
        ])
        cube([
            box_hang_width-box_hang_eps*4,
            box_hang_eps,
            fix    
        ]);
    }
}

module box_hang_void() {
    hull() {
        translate([box_hang_label_margin, +box_hang_label_margin,fix])
        cube([box_hang_width-box_hang_label_margin*2, box_hang_length, fix]);
        translate([
            box_hang_label_margin-box_hang_eps,
            +box_hang_label_margin-box_hang_eps,
            -box_hang_eps
        ])
        cube([
            box_hang_width-box_hang_label_margin*2+box_hang_eps*2,
            box_hang_length,
            fix
        ]);    
    }
}



module box_hang() {
    difference() {
        box_hang_solid();
        box_hang_void();
    }
    box_hang_firm();
}

module box_main(box_width, box_length, box_depth) {
    difference() {
        cube([box_width, box_length, box_depth]);

        translate([box_wall_thick,box_wall_thick,box_bottom_thick])
        cube([box_width-box_wall_thick*2, box_length-box_wall_thick*2, box_depth]);
    };
}

module box_main_outer(box_width, box_length, box_depth) {
    module solid() {
        intersection() {
            translate([gap,-gap,0])
            cube([box_width, box_length, box_depth]);
            reduce(gap)
            smooth();
        }
    }
    
    translate([-gap,gap,0])
    difference() {
        solid();

        translate([0,0,box_bottom_thick])
        reduce(box_wall_thick)
        solid();    
    };
}



module box(box_width, box_length, box_depth) {
    module move_hang() {
        translate([
            (box_width-box_hang_width)/2,
            box_length-box_hang_length,
            box_depth
        ])
        children();
    }

    
    difference() {
        union() {
            box_main(box_width, box_length, box_depth);
            move_hang()
            box_hang_solid();
        };
        move_hang()
        box_hang_void();
    }
    move_hang()
    box_hang_firm();
}

module box_outer(box_width, box_length, box_depth) {
    module move_hang() {
        translate([
            (box_width-box_hang_width)/2,
            box_length-box_hang_length,
            box_depth
        ])
        children();
    }

    
    difference() {
        union() {
            box_main_outer(box_width, box_length, box_depth);
            move_hang()
            box_hang_solid();
        };
        move_hang()
        box_hang_void();
    }
    move_hang()
    box_hang_firm();
}

box_width_25 = (width-gap*5)/4;
box_length_20 = (length_max-gap*6)/5;

box_length_20_bc = length_min-gap*6-box_length_20*4 - gap;

module box_grid() {
    
    for ( i = [0:3]) {
        for ( j = [0:3]) {
            x_shift = gap+(box_width_25+gap)*j;
            y_shift = gap+(box_length_20+gap)*i;
            
            translate([x_shift, length_max-box_length_20-y_shift,0])
            box(box_width_25, box_length_20, depth);
        }
    }
    x1_shift = gap+(box_width_25+gap)*0;
    y1_shift = gap+(box_length_20+gap)*4;
    
    translate([x1_shift, length_max-box_length_20-y1_shift,0])
    box_outer(box_width_25, box_length_20, depth);
    
    x2_shift = gap+(box_width_25+gap)*3;
    y2_shift = gap+(box_length_20+gap)*4;
    
    translate([box_width_25+x2_shift, length_max-box_length_20-y2_shift,0])
    mirror([1,0,0])
    box_outer(box_width_25, box_length_20, depth);
    
    x3_shift = gap+(box_width_25+gap)*1;
    y3_shift = gap+(box_length_20+gap)*4;
    
    translate([x3_shift, length_max-box_length_20_bc-y3_shift,0])
    box(box_width_25, box_length_20_bc, depth);
    
    x4_shift = gap+(box_width_25+gap)*2;
    y4_shift = gap+(box_length_20+gap)*4;
    
    translate([x4_shift, length_max-box_length_20_bc-y4_shift,0])
    box(box_width_25, box_length_20_bc, depth);
    
}



//translate([0,0,0.5])
//box_grid();

//cassetto();

module box_test() {
    difference() {
        box(45,40,7);
        translate([-10,-2,-5])
        cube([70,30,30]);   
       translate([0,0,-130]) 
        cube([70,130,130]);    
    }
}

//box_test();

//box(box_width_25, box_length_20, depth);
//box_outer(box_width_25, box_length_20, depth);
box(box_width_25, box_length_20_bc, depth);

//box_main_outer(box_width_25, box_length_20, depth);

//intersection() {    
//    box_hang();
//    translate([0,0,-2])
//    cube([100,100,3]);
//}






    
