export default {
  // remove the next line if not running on our VM and connection to PostgreSQL doesn't work
  host: '/var/run/postgresql',

  database: 'hangmanDB',
  statement_timeout: 5000,
};