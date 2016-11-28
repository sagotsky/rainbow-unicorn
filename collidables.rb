


__END__

TODO: how to collide?
idea: drawing each frame we know how much time has gone by since last frame.  figure out the time when objects would have hit.

# takes place when an actor moves.  not world movement, so not in physics.  maybe physics -> worldphysics or world
module Collidables
  def self.register(object)
    objects << object
  end

  def self.objects
    @objects ||= Set.new
  end

  def object_will_move(moving_object, new_position)
    Collidables.objects.select do |bystander|
      return false if moving_object == bystander # don't collide with self

      # does collision_between take into account the path the object passes?  if velocity > height, a falling object could bypass the ground
      # also, moves should include vector.  something moving downright 5 past a should clip it.
      # rotattin?!?!?!
      if collision_between?(bystander, moving_object, new_position)
        
      end
      # does a position have dimensions too?


    end
  end

  def collision_between?(bystander, moving_object, new_position)

  end
end


# collisions are not phsyics.  they happen during moves, not during the physics loop.
# mobs can collide with mobs.  or with platforms.  will platforms ever collide?
# collidables might need to define what their collisions do
# some items might collide with each other.
# types:
#   pc
#   npc
#   platform
#   projectible/powerup
#   trampoline

