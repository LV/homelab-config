_:

{
  users.groups.media = { };

  users.users.v.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d /srv/media                  2775 root media -"
    "d /srv/media/torrents         2775 root media -"
    "d /srv/media/library          2775 root media -"
    "d /srv/media/library/movies   2775 root media -"
    "d /srv/media/library/shows    2775 root media -"
  ];
}
