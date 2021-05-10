bash_ksqldb:
	@docker exec -it ksqldb ksql http\://ksqldb\:8088

clean_all:
	@docker-compose down --rmi all

start_containers:
	@docker-compose --env-file .env.aws_credentials up -d

register_partition_default:
	@./sink_s3_partition_default.sh

register_partition_by_hour:
	@./sink_s3_partition_by_hour.sh

register_partition_by_hour_snappy:
	@./sink_s3_partition_by_hour_snappy.sh
