local db_mysql = {}

db_mysql.store_log = {
    -- sql = [[insert into db_player.player_base_info (uid, nickname, gender, image_url) values($uid, '$nickname',$gender, '$image_url')]],
     sql = [[insert game_result_log (room_id, game_index, owner, end_time, game_action, game_result,chair_1_uid,chair_1_point,chair_2_uid, chair_2_point,chair_3_uid, chair_3_point, chair_4_uid, chair_4_point ) 
     		 values('$room_id', $game_index, $owner, '$end_time',  '$game_action' , '$game_result', $chair_1_uid, $chair_1_point,$chair_2_uid, $chair_2_point,$chair_3_uid, $chair_3_point,$chair_4_uid, $chair_4_point)]],
     
}

db_mysql.room_result = {
	sql = [[ insert room_result_log (room_id, end_time, game_num, owner, chair_1_uid, chair_1_name, chair_1_point, chair_2_uid, chair_2_name, chair_2_point, chair_3_uid, chair_3_name, chair_3_point, chair_4_uid, chair_4_name, chair_4_point)
			 values('$room_id', '$end_time', $game_num, $owner,$chair_1_uid, '$chair_1_name', $chair_1_point, $chair_2_uid, '$chair_2_name', $chair_2_point, $chair_3_uid, '$chair_3_name', $chair_3_point, $chair_4_uid, '$chair_4_name', $chair_4_point)
			]]
}

db_mysql.build_room_log = {
	sql = [[
		insert build_room_log (room_id, node_name, create_time, owner, game_type, game_count, player_count,type, config, club_id)
								values('$room_id', '$node_name', '$create_time', $owner, $game_type, $game_count, $player_count, $type, '$config', '$club_id')
	]]
}

db_mysql.game_statistics_log = {
	sql = [[
		insert game_statistics (room_peak, online_peak, time)
								values('$room_peak', '$online_peak', '$time')
	]]
}
return db_mysql
