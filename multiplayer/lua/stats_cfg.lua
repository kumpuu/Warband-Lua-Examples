--Settings for database

return {
  db_path = "%storage%\\db\\stats.sqlite3",
  backup_folder = "%storage%\\db\\",
  num_backups = 3,

  --The layout of our user table
  --id = game unique id
  init_query = [[
    CREATE TABLE IF NOT EXISTS users (
      id               INTEGER PRIMARY KEY,
      last_username    TEXT,
      last_ip          TEXT,
      last_date_online TEXT,
      kills            INTEGER DEFAULT 0,
      deaths           INTEGER DEFAULT 0,
      hp_healed        INTEGER DEFAULT 0,
      seconds_online   INTEGER DEFAULT 0,
      chat_msgs_sent   INTEGER DEFAULT 0,
      local_msgs_sent  INTEGER DEFAULT 0,
      chat_chars_sent  INTEGER DEFAULT 0,
      props_built      INTEGER DEFAULT 0,
      tnt_placed       INTEGER DEFAULT 0,
      ft1_wins         INTEGER DEFAULT 0,
      ft3_wins         INTEGER DEFAULT 0,
      ft5_wins         INTEGER DEFAULT 0,
      ft7_wins         INTEGER DEFAULT 0,
      ft1_losses       INTEGER DEFAULT 0,
      ft3_losses       INTEGER DEFAULT 0,
      ft5_losses       INTEGER DEFAULT 0,
      ft7_losses       INTEGER DEFAULT 0,
      tag_wins         INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS known_user_names (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      known_username TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id)
    );
    ]],

  --If you have an existing db and want to add more columns when it's loaded, add them here
  new_columns = {
    {column = "n_words", type = "INTEGER", default = 0}
  },

  --For displaying to user
  full_column_names = {
    id = "uid",
    last_username = "Last Username",
    last_ip = "Last IP",
    last_date_online = "Last Online",
    kills = "Kills",
    deaths = "Deaths",
    hp_healed = "HP healed",
    seconds_online = "Total Seconds Online",
    chat_msgs_sent = "Chat Messages sent",
    local_msgs_sent = "Local Chat Messages sent",
    chat_chars_sent = "Chat Letters typed",
    props_built = "Props built",
    tnt_placed = "TNT placed",
    ft1_wins = "Duel Wins",
    ft3_wins = "Ft3 Wins",
    ft5_wins = "Ft5 Wins",
    ft7_wins = "Ft7 Wins",
    ft1_losses = "Duel Wins",
    ft3_losses = "Ft3 Wins",
    ft5_losses = "Ft5 Wins",
    ft7_losses = "Ft7 Wins",
    tag_wins = "Tag Event Wins",
    n_words = "N Words",
  },

  --for /top command
  --stat is the string you can use for /top (stat)
  --col is column name in users. It will run a default query for that column. It will also use a caption from full_column_names, if none provided
  top_data = {
    {stat = "kd",
      caption = "K/D",
      query = "SELECT last_username, ROUND(kills*1.0/deaths,2) as kd, kills, deaths FROM users WHERE kills > 100 AND deaths > 0 ORDER BY kd DESC LIMIT %d",
      formatter = function(row) return string.format("%.2f (%d Kills, %d Deaths)", row[2], row[3], row[4]) end
    },
    {stat = "hours", col = "seconds_online", caption = "Hours Online", formatter = function(row) return string.format("%.2f", row[2] / 60 / 60) end},
    {stat = "kills", col = "kills"},
    {stat = "deaths", col = "deaths"},
    {stat = "heal", col = "hp_healed"},
    {stat = "chat", col = "chat_msgs_sent"},
    {stat = "local", col = "local_msgs_sent"},
    {stat = "letters", col = "chat_chars_sent"},
    {stat = "props", col = "props_built"},
    {stat = "tnt", col = "tnt_placed"},
    {stat = "tag", col = "tag_wins"},
    -- {"nword", "n_words"}
    {stat = "duel", 
      caption = "Duel",
      query = "SELECT last_username, ROUND(ft1_wins*1.0/ft1_losses,2) as kd, ft1_wins, ft1_losses FROM users WHERE ft1_wins > 10 AND ft1_losses > 0 ORDER BY kd DESC LIMIT %d",
      formatter = function(row) return string.format("%.2f (%d Wins, %d Losses)", row[2], row[3], row[4]) end
    },
    {stat = "ft3", 
      caption = "FT3",
      query = "SELECT last_username, ROUND(ft3_wins*1.0/ft3_losses,2) as kd, ft3_wins, ft3_losses FROM users WHERE ft3_wins > 10 AND ft3_losses > 0 ORDER BY kd DESC LIMIT %d",
      formatter = function(row) return string.format("%.2f (%d Wins, %d Losses)", row[2], row[3], row[4]) end
    },
    {stat = "ft5", 
      caption = "FT5",
      query = "SELECT last_username, ROUND(ft5_wins*1.0/ft5_losses,2) as kd, ft5_wins, ft5_losses FROM users WHERE ft5_wins > 10 AND ft5_losses > 0 ORDER BY kd DESC LIMIT %d",
      formatter = function(row) return string.format("%.2f (%d Wins, %d Losses)", row[2], row[3], row[4]) end
    },
    {stat = "ft7", 
      caption = "FT7",
      query = "SELECT last_username, ROUND(ft7_wins*1.0/ft7_losses,2) as kd, ft7_wins, ft7_losses FROM users WHERE ft7_wins > 10 AND ft7_losses > 0 ORDER BY kd DESC LIMIT %d",
      formatter = function(row) return string.format("%.2f (%d Wins, %d Losses)", row[2], row[3], row[4]) end
    },
  },

  --These columns get shown for /stats
  stats_query = [[
    SELECT
      seconds_online, 
      kills, 
      deaths, 
      hp_healed, 
      chat_msgs_sent, 
      local_msgs_sent, 
      chat_chars_sent, 
      props_built,
      tnt_placed,
      tag_wins
    FROM users 
    WHERE id = ?
    ]],

  --These columns get shown for /duelstats
  duelstats_query = [[
    SELECT
      ft1_wins, 
      ft3_wins, 
      ft5_wins, 
      ft7_wins,
      ft1_losses, 
      ft3_losses, 
      ft5_losses, 
      ft7_losses
    FROM users 
    WHERE id = ?
    ]],
}
