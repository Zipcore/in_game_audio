class Ability
  include CanCan::Ability

  #:read, :create, :update, :destroy
  def initialize(user, access_token=nil)
    can :read, Directory
    can :read, Song
    can :read, User

    cannot :admin, :page

    #Checks for logged in users
    if user && !user.banned?

      cannot :manage, Theme
      can :manage, Theme, user_id: user.id

      if user.uploader?
        can :create, Song
        can :manage, Song, uploader_id: user.id
        cannot :map_themeable, Song
        cannot :user_themeable, Song
      end

      if user.admin?
        can :manage, :all
        cannot [:update, :destroy], Directory, root: true
      end
    end

    #Checks for the api system
    if access_token && ApiKey.authenticate(access_token)
      can :manage, :api
    end

    #Checks for a registered play-event through the api
    if access_token && play_event = PlayEvent.authenticate(access_token)
      can :play, Song do |song|
        song.id == play_event.song_id
      end
    end

  end
end
