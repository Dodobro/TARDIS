-- Default

local INT={}
INT.Name="Default"
INT.ID="default"
INT.Model="models/drmatt/tardis/2012interior/interior.mdl"
INT.IdleSound={
	{
		path="drmatt/tardis/interior_idle_loop.wav",
		volume=1	
	},
}
INT.Light={
	color=Color(0,100,255),
	pos=Vector(0,0,0),
	brightness=8
}
INT.ScreenX=485
INT.ScreenY=250
INT.RoundThings={
	Vector(-257,-383,222.5),
	--Vector(-324.74,-310.87,222.5),
	--Vector(-371.58,-271.56,222.5),
	--Vector(-402.3,-175.17,222.5),
	--Vector(-418.7,-123.74,222.5),
	--Vector(-449.7,-26.48,222.5),
	--Vector(-444.74,29.44,222.5),
	--Vector(-414.83,123.27,222.5),
	--Vector(-398.5,174.51,222.5),
	--Vector(-363.36,269.67,222.5),
	--Vector(-318.57,302.84,222.5),
	--Vector(-237.87,362.61,222.5),
	--Vector(-196.91,392.94,222.5),
	--Vector(-103.69,432.7,222.5),
	--Vector(-51.12,432.7,222.5),
	Vector(51.75,460,222.5),
	--Vector(104.76,432.7,222.5),
	--Vector(198.82,386.66,222.5),
	--Vector(238.42,357.33,222.5),
	--Vector(317.29,301.46,222.5),
	--Vector(366.49,269.05,222.5),
	--Vector(396.84,173.72,222.5),
	--Vector(413.4,122.04,222.5),
	--Vector(444.76,24.65,222.5),
	--Vector(446.2,-28.22,222.5),
	--Vector(414.35,-116.72,222.5),
	--Vector(396.13,-173.9,222.5),
	--Vector(365.36,-270.42,222.5),
	--Vector(321.86,-308.13,222.5),
	--Vector(242.69,-366.76,222.5),
}
INT.Portal={
	pos=Vector(-1,-353.5,136),
	ang=Angle(0,90,0),
	width=60,
	height=91
}
INT.Fallback=Vector(0,-330,95)
INT.Screens={
	{
		pos=Vector(57.15,-11.38,159.58),
		ang=Angle(0,90,90)
	},
	{
		pos=Vector(-56,18.4,159.58),
		ang=Angle(0,-90,90)
	}
}
INT.Parts={
	console={
		model="models/drmatt/tardis/2012interior/console.mdl"
	},
	door={},
	test={
		pos=Vector(-1.5,-50,130),
		ang=Angle(0,-90,0)
	},
}

ENT:AddInterior(INT)