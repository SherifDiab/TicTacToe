## StatsStore.gd
## Manages game statistics persistence using ConfigFile.
## Autoloaded singleton for global access.
extends Node

const SAVE_PATH := "user://tictactoe_stats.cfg"
const SECTION := "stats"

# Stats structure
var stats := {
	"total_games": 0,
	"wins": 0,
	"losses": 0,
	"draws": 0,
	"wins_easy": 0,
	"wins_medium": 0,
	"wins_hard": 0,
	"losses_easy": 0,
	"losses_medium": 0,
	"losses_hard": 0,
	"draws_easy": 0,
	"draws_medium": 0,
	"draws_hard": 0,
	"current_streak": 0,
	"best_streak": 0
}

# Signal for stats updates
signal stats_updated


func _ready() -> void:
	load_stats()


## Loads stats from disk
func load_stats() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)

	if err != OK:
		# First run or corrupted file, use defaults
		save_stats()
		return

	for key in stats.keys():
		stats[key] = config.get_value(SECTION, key, stats[key])

	stats_updated.emit()


## Saves stats to disk
func save_stats() -> void:
	var config := ConfigFile.new()

	for key in stats.keys():
		config.set_value(SECTION, key, stats[key])

	var err := config.save(SAVE_PATH)
	if err != OK:
		push_error("Failed to save stats: " + str(err))


## Records a game result
func record_game(result: Dictionary) -> void:
	stats["total_games"] += 1

	var difficulty_suffix := "_" + result.get("difficulty", "medium").to_lower()

	if result.get("is_draw", false):
		stats["draws"] += 1
		stats["draws" + difficulty_suffix] = stats.get("draws" + difficulty_suffix, 0) + 1
		stats["current_streak"] = 0
	elif result.get("human_won", false):
		stats["wins"] += 1
		stats["wins" + difficulty_suffix] = stats.get("wins" + difficulty_suffix, 0) + 1
		stats["current_streak"] += 1
		if stats["current_streak"] > stats["best_streak"]:
			stats["best_streak"] = stats["current_streak"]
	else:
		stats["losses"] += 1
		stats["losses" + difficulty_suffix] = stats.get("losses" + difficulty_suffix, 0) + 1
		stats["current_streak"] = 0

	save_stats()
	stats_updated.emit()


## Gets a specific stat value
func get_stat(key: String) -> int:
	return stats.get(key, 0)


## Gets all stats as dictionary
func get_all_stats() -> Dictionary:
	return stats.duplicate()


## Calculates win rate as percentage
func get_win_rate() -> float:
	var total: int = stats["total_games"]
	if total == 0:
		return 0.0
	return (float(stats["wins"]) / float(total)) * 100.0


## Calculates win rate for a specific difficulty
func get_win_rate_for_difficulty(difficulty: String) -> float:
	var suffix := "_" + difficulty.to_lower()
	var wins: int = stats.get("wins" + suffix, 0)
	var losses: int = stats.get("losses" + suffix, 0)
	var draws: int = stats.get("draws" + suffix, 0)
	var total := wins + losses + draws

	if total == 0:
		return 0.0
	return (float(wins) / float(total)) * 100.0


## Resets all stats
func reset_stats() -> void:
	for key in stats.keys():
		stats[key] = 0
	save_stats()
	stats_updated.emit()


## Gets a formatted stats summary string
func get_stats_summary() -> String:
	var total: int = stats["total_games"]
	var wins: int = stats["wins"]
	var losses: int = stats["losses"]
	var draws: int = stats["draws"]
	var win_rate := get_win_rate()

	var summary := "Games: %d | W: %d | L: %d | D: %d\n" % [total, wins, losses, draws]
	summary += "Win Rate: %.1f%% | Streak: %d (Best: %d)" % [win_rate, stats["current_streak"], stats["best_streak"]]

	return summary


## Gets detailed stats for a specific difficulty
func get_difficulty_stats(difficulty: String) -> Dictionary:
	var suffix := "_" + difficulty.to_lower()
	return {
		"wins": stats.get("wins" + suffix, 0),
		"losses": stats.get("losses" + suffix, 0),
		"draws": stats.get("draws" + suffix, 0),
		"win_rate": get_win_rate_for_difficulty(difficulty)
	}
