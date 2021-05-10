# Kafka connect S3 Sink

Passo a passo de como enviar os dados do Kafka local para o AWS S3 usando o Kafka-connect S3 sink

- sink_s3_partion_by_hour.sh - Usa o timestamp do momento que a mensagem chegou no kafka para criar partição no S3 por hora
  no formato 'topic/year=YYYY/month=MM/day=dd/hour=HH/topic+kafkaPartition+startOffset.avro'.

- sink_s3_partion_by_hour_snappy.sh - Usa o timestamp do momento que a mensagem chegou no kafka para criar partição no S3 por hora
  no formato 'topic/year=YYYY/month=MM/day=dd/hour=HH/topic+kafkaPartition+startOffset.avro.snappy' compactado com snappy.

- sink_s3_partition_default.sh - Cria partição no S3 no formato 'topic/partition=kafkaPartition/topic+kafkaPartition+startOffset.avro'

## Pré-requisitos:

- Docker + Docker-compose
- Conta na AWS

## Passos:

1 - Crie sua conta pessoal na [AWS](http://comunidadecloud.com/post/como-criar-uma-conta-na-aws/).

2 - Crie um bucket no S3 para receber os dados.
    
- Nome do bucket: rmoff-voluble-hourly-partitioner 
  
- Region: US East(N. Virginia) us-east-1
   
3 - Crie uma credencial do tipo chave de acesso na [AWS](https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials).

**Nota**: Não esqueça de fazer download da credencial e salvar o arquivo em um ambiente seguro. A credencial será usada nos próximos passos.
    
4 - Preencha as variáveis AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY definidas no arquivo `.env.aws_credentials`.

5 - Abra o terminal para inicializar os serviços definidos no arquivo docker-compose.yaml.
    
    $ make start_containers

6 - Verifique se todos serviços estão de pé(zookeeper, broker, schema-registry, kafka-connect, ksqldb).
    
    $ docker-compose ps

7 - Entre no Ksqldb para fazer ingestão dos dados no kafka usando [Voluble](https://github.com/MichaelDrogalis/voluble).

    $ make bash_ksqldb
   ksql> [script voluble](https://github.com/MichaelDrogalis/voluble#quick-example)

8 - Dentro do ksqldb, verifique se os tópicos Voluble foram criados com as mensagens.
    
    ksql> show topics;
    ksql> print cats limit 10;

9 - Para visualizar os schemas avros criados.

    $ curl -X GET http://localhost:8081/subjects
    $ curl -X GET http://localhost:8081/subjects/cats-value/versions/1

10 - Abra outro terminal para registrar o conector 'sink-s3-voluble-hourly-partitioner' no Kafka-connect para consumir dados do tópico 'cats' e enviar para o bucket 'rmoff-voluble-hourly-partitioner' no S3.
    
    $ chmod +x sink_s3_partition_by_hour.sh
    $ make register_partition_by_hour

11 - Execute o comando para ver o conector criado 'sink-s3-voluble-hourly-partitioner'.
    
    ksql> show connectors;

12 - Visto alguns arquivos no bucket 'rmoff-voluble-hourly-partitioner' no S3, faça o kill em todos os processos para não atingir o limite de 5G gratuito no [S3](https://aws.amazon.com/pt/free/?all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all).

    $ docker-compose down

## Referências

* [Schema Registry](https://github.com/confluentinc/schema-registry)
* [From Zero to Hero with Kafka Connect](https://rmoff.dev/crunch19-zero-to-hero-kafka-connect)
* [Confluent Hub](https://hub.confluent)
* [S3 Sink connector docs](https://docs.confluent.io/current/connect/kafka-connect-s3/index.html#connect-s3)
* [Voluble Source connector docs](https://github.com/MichaelDrogalis/voluble)
* [Single Message Transform blog](https://www.confluent.io/blog/simplest-useful-kafka-connect-data-pipeline-world-thereabouts-part-3/)
* [InsertField -Single Message Transform](https://docs.confluent.io/current/connect/transforms/insertfield.html)
