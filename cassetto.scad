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
depth = 75;
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
    linear_extrude(height=depth+fix*3)
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
box_bottom_thick = 3;
box_wall_thick = 3;


box_hang_label_width = 30;
box_hang_label_length = 10;
box_hang_label_margin = 2;
box_hang_play = 0.3;
box_hang_eps = 0.7;
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
            cube([box_width, box_length, box_depth]);
            reduce_y(gap)
            smooth();
        }
    }
    
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
}

box_width_25 = (width-gap*5)/4;
box_length_20 = (length_max-gap*6)/5;

module box_grid() {
    
    for ( i = [0:3]) {
        for ( j = [0:3]) {
            x_shift = gap+(box_width_25+gap)*j;
            y_shift = gap+(box_length_20+gap)*i;
            
            translate([x_shift, length_max-box_length_20-y_shift,0])
            box(box_width_25, box_length_20, depth);
        }
    }
    x_shift = gap+(box_width_25+gap)*0;
    y_shift = gap+(box_length_20+gap)*4;
    color("red")
    translate([x_shift, length_max-box_length_20-y_shift,0])
    box_main_outer(box_width_25, box_length_20, depth);
}



translate([0,0,0.5])
box_grid();

cassetto();

//box_main_outer(box_width_25, box_length_20, depth);






    