
import image as I
import reactors as R


WIDTH = 800
HEIGHT = 500

Blank-canvas = I.empty-scene(WIDTH,HEIGHT)


#The X-wing

x-wing =I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1XwEutXxWvmVNNolLMrjw0Cu8n1UopoDI")


#Background images to change

img0 = I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1thZZ5QOUd0emtB6aShweb1DxZLehIfcT")

img1 = I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1ItbRsengumMXPb7LcQF5pwtoP03vNTwG")

img2 = I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1XAYFSZpJIaLZpobjq4s9gcm0AEIVMruF")

img3 = I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=174OmCRSsKccmMKux8QtH3TfY2OckGt67")

img4 = I.image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1xx1CkF0tX88UwP8QbXUiwx3s7jLcQaFN")


backgrounds = [list : img0, img1, img2,img3, img4, img3, img2, img1]


#Blue laser to shoot
blue-laser = overlay(rectangle(2, 13, 'solid','aqua'),rectangle(4, 15, 'solid','blue'))

#Asteroid
ast0 = image-url("https://code.pyret.org/shared-image-contents?sharedImageId=1YI0Rh_n-pLNWtHpedNFtA8wWImBs46fm")




######### THE PROGRAM ###############

data TheWorld:
  |world(player :: Posn, index :: Number, lasers :: List<Posn>, asteroids :: List<Posn>, score :: Number)
end

data Posn:
  |posn(x :: Number, y :: Number)
end

fun game-stops(w):
  doc: 'if there are more than 5 asteroids in the screen the game ends'
  if length(w.asteroids) >= 5:
    true
  else:
    false
  end
end

fun place-elements(w):
  doc: 'funtion to pass on "to draw" reactor command'
  
  BG = I.place-image(backgrounds.get(w.index), WIDTH / 2, HEIGHT / 2, Blank-canvas) 
  frame1 = I.place-image(x-wing, w.player.x,w.player.y,BG)
  frame2 = w.lasers.foldl(lam(a,acc): I.place-image(blue-laser, a.x, a.y - 60, acc) end, frame1)
  frame3 = w.asteroids.foldl(lam(a, acc): I.place-image(ast0, a.x, a.y, acc) end, frame2)
  if game-stops(w):
    lost = text("You Lost :( || ; Score :" + num-to-string(w.score), 56, "red")
    I.place-image(lost, WIDTH / 2, HEIGHT / 2, frame3)
  else:
    frame3
  end
end

fun random-num-gen(w) -> Boolean:
  doc: 'checks whether a random number generated is less than 4'
  num-random(16) < 4
end

fun anew-laser(w):
  doc: 'adds a new laser to the list of lasers'
  lsr = posn(w.player.x, w.player.y - 15)
  world(posn(w.player.x, w.player.y),w.index, link(lsr, w.lasers),w.asteroids, w.score)
end

fun move-laser(w):
  doc:' moves all lasers which are below the top of the screen to the top of the screen'
  l-abv-can = (w.lasers).filter(lam(p): p.y > 0 end)
  l-abv-can.map(lam(p): posn(p.x,p.y - 35) end)
end

fun anew-asteroid(w):
  doc: 'adds a new asteroid to the list of asteroids'
  aster = posn(random(WIDTH), 0)
  world(posn(w.player.x, w.player.y),w.index, w.lasers,link(aster,w.asteroids),w.score)
end

fun move-asteroid(w):
  doc: 'moves all asteroids above the x axis towards the x axis'
  ast-bel-can = (w.asteroids).filter(lam(a): a.y < HEIGHT end)
  ast-bel-can.map(lam(a): posn(a.x, a.y + (num-random(10) + 30)) end)
end



########

Coll-thresh = 75    #Collision threshold


fun distance(p1, p2):     #Gives the distance between two Posn
  fun nsquare(n): n * n end
  num-sqrt(nsquare(p1.x - p2.x) + nsquare(p1.y - p2.y))
end


fun collision-check(aster, lsr):
  doc: 'checks the collision between lasers and asteroid'
  
  
  fun asteroid-no-hit(ast, l) -> Boolean:
    doc: 'takes the list of asteroids and checks whether a single laser is colliding with it'
    ast.foldl(lam(e, acc): acc and (distance(l, e) >= Coll-thresh) end, true)
  end
  
  fun laser-no-hit(lasr, a) -> Boolean:
    doc: 'takes the list of lasers and checks whether a single asteroid is colliding with it'
    lasr.foldl(lam(e, acc): acc and (distance(a, e) >= Coll-thresh) end, true)
  end
  
  fun hit-ast(ast, l):
    ast.foldl(lam(e, acc): acc and (distance(l, e) < Coll-thresh) end, true)
  end
  
  no-hit-laser = lsr.filter(lam(x): asteroid-no-hit(aster,x) end) #calls the function and checks this for every laser and returns a list of lasers which are not colliding.
  
  no-hit-aster = aster.filter(lam(x): laser-no-hit(lsr,x) end)  #calls the function and checks it for every asteroid and returns a list of asteroids which are not colliding.
  
  hi-ast = aster.filter(lam(x): hit-ast(lsr, x) end)
  
  {no-hit-laser ; no-hit-aster ; hi-ast} # returns a tuple containing both of the lists to update the world.
end



#####

fun on-time-canvas(w):
  
  doc: 'the funtion to pass on to the "on-tick" reactor command'
  
  all-asteroids = move-asteroid(w)
  
  all-lasers = move-laser(w)
  
  no-hit-obj = collision-check(all-asteroids, all-lasers)
  
  if random-num-gen(w):
    
    time = world(w.player, num-modulo(w.index + 1, length(backgrounds)),no-hit-obj.{0},no-hit-obj.{1},length(no-hit-obj.{2}))
    
    anew-asteroid(time)
    
  else:
    
    world(w.player, num-modulo(w.index + 1, length(backgrounds)),no-hit-obj.{0},no-hit-obj.{1}, length(no-hit-obj.{2}))
  end
end


KEY-DISTANCE = 10

fun move-objects-key(w, key):
  ask:
    | key == "left"   then: world(posn(w.player.x - KEY-DISTANCE,w.player.y), w.index,w.lasers,w.asteroids,w.score)
    | key == "right" then: world(posn(w.player.x + KEY-DISTANCE,w.player.y), w.index,w.lasers,w.asteroids, w.score)
    | key == "up" then: anew-laser(w)
    | otherwise: w
  end
end

INIT-POS = posn(WIDTH / 2, HEIGHT - 60)
THE-WORLD = world(INIT-POS,0,[list:],[list:], 0)


anim = reactor:
  init: THE-WORLD,
  title: "X-Wing",
  on-key: move-objects-key,
  to-draw: place-elements,
  on-tick: on-time-canvas,
  stop-when: game-stops,
  seconds-per-tick: 0.5
end

R.interact(anim) 
