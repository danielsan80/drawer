include <bezier.scad>;

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
            [handle_side_max+10,length_min_offset+50],
            [0,length_min_offset+50]
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


difference() {
    solid();
    void();
    smooth();
    translate([width,0,0])
    mirror([1,0,0])
    smooth();
}




    