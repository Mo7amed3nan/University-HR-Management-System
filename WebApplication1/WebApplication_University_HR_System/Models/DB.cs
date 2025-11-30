using System.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace WebApplication_University_HR_System.Models
{
    public class DB
    {
        private readonly string _connectionString;

        public DB(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public SqlConnection Connect()
        {
            return new SqlConnection(_connectionString);
        }
    }
}