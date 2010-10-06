
var ocean : Ocean;
// Water plane at y = 0
private var mag = 1.0;

private var ypos = 0.0;
private var blobs : Array;
private var ax = 2.0;
private var ay = 2.0;

private var dampCoeff = .2;

private var engine = false;

function Start () {
	
//	mag = rigidbody.mass / (ax * ay) * 10;
	rigidbody.centerOfMass = Vector3 (0.0, -0.5, 0.0);
	
	var bounds = GetComponent("MeshCollider").mesh.bounds.size;
	var length = bounds.z;
	var width = bounds.x;

	blobs = new Array();
	blobs.length = ax * ay;
	var i = 0;
	xstep = 1.0 / (ax-1);
	ystep = 1.0 / (ay-1);
	
	var point;
	var velocity;
	for (x=0;x<ax;x++){
		for (y=0;y<ay;y++){		
			blobs[i] = Vector3 ((-0.5+x*xstep)*width, 0.0, (-0.5+y*ystep)*length) + Vector3.up*ypos;
			i++;
		}		
	}
}

function Update (){
//	if (Input.GetButton ("Fire1")){
//		engine = !engine;
		//blobs[0] = null;
//	}
}

function FixedUpdate () {
	for (i=0; i<blobs.length;i++) {
		var blob = blobs[i];
		if (blob != null) {
		wpos = transform.TransformPoint (blob);
	 	damp = rigidbody.GetPointVelocity(wpos).y;
		if (ocean)
			rigidbody.AddForceAtPosition (-Vector3.up * (mag * (wpos.y - ocean.GetWaterHeightAtLocation (wpos.x, wpos.z)) + dampCoeff*damp) , wpos);		
		else
			rigidbody.AddForceAtPosition (-Vector3.up * (mag * (wpos.y ) + dampCoeff*damp) , wpos);		
		
	}
	if (engine)
		rigidbody.AddForceAtPosition (transform.forward*40.0, transform.TransformPoint (Vector3 (0.0, -1.0, -7.5)));		
	
}

}