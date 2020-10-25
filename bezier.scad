deltat = 0.05;
    
function cubic_bezier(p0,p1,p2,p3) = [for (t=[0:deltat:1+deltat]) pow(1-t,3)*p0+3*pow((1-t),2)*t*p1+3*(1-t)*pow(t,2)*p2+pow(t,3)*p3];

function project_point(pa, pb) =
    [for (i = [0:1]) pb[i]+(pb[i]-pa[i])];
    
module polyline(points, index, w) {
    if(index < len(points)) {
        line(points[index - 1], points[index],w);
        polyline(points, index + 1, w);
    }
}

module line(p1,p2,w) {
    hull() {
        translate(p1) circle(r=w,$fn=20);
        translate(p2) circle(r=w,$fn=20);
    }
}