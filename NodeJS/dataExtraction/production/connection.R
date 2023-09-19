# Accessing databse
con = dbConnect(RPostgres::Postgres(),
                dbname = "bus_trial",
                port = 5432,
                user = "postgres",
                password = "postgres",
                host = "localhost")