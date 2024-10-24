using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace App
{
    class Database
    {
        private static SqlConnection connection
            = connection = new SqlConnection("Data Source=.;Initial Catalog=UserManagement;Integrated Security=True");
        public static void Execute(string sql, Dictionary<string, object> parameters = null)
        {
            using (var connection = new SqlConnection("Data Source=.;Initial Catalog=UserManagement;Integrated Security=True"))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(sql, connection);
                if (parameters != null)
                    foreach (string key in parameters.Keys)
                        command.Parameters.Add(new SqlParameter(key, parameters[key]));
                try
                {
                    command.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    connection.Close();
                }
            }
        }
        public static DataTable Query(string sql, Dictionary<string, object> parameters = null)
        {
            DataTable table = new DataTable();

            using (var connection = new SqlConnection("Data Source=.;Initial Catalog=UserManagement;Integrated Security=True"))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(sql, connection);
                if (parameters != null)
                    foreach (string key in parameters.Keys)
                        command.Parameters.Add(new SqlParameter(key, parameters[key]));
                SqlDataAdapter adapter = new SqlDataAdapter(command);
                adapter.Fill(table);
                connection.Close();
            }
            return table;
        }

    }
}
