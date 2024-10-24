using System;
using System.Collections.Generic;
using System.Data;
using System.Windows.Forms;

namespace App
{
    public partial class UserManagement : Form
    {
        public UserManagement()
        {
            InitializeComponent();
            load();
        }

        private void dgvThongTin_RowEnter(object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                txtId.Text = dgvThongTin.Rows[e.RowIndex].Cells["ID"].Value.ToString();
                txtEmail.Text = dgvThongTin.Rows[e.RowIndex].Cells["EMAIL"].Value.ToString();
                txtFullName.Text = dgvThongTin.Rows[e.RowIndex].Cells["FULL_NAME"].Value.ToString();
                txtPhone.Text = dgvThongTin.Rows[e.RowIndex].Cells["PHONE"].Value.ToString();
                cboRole.SelectedItem = dgvThongTin.Rows[e.RowIndex].Cells["ROLE"].Value.ToString();
                cboPhongBan.Text = dgvThongTin.Rows[e.RowIndex].Cells["DEPARTMENT_NAME"].Value.ToString();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        void load()
        {
            DataTable dt = Database.Query("EXEC SP_SEL_DECRYPT_USER");
            dgvThongTin.DataSource = dt;

            DataTable dtDepartments = Database.Query("SELECT ID, NAME FROM Department");
            cboPhongBan.DataSource = dtDepartments;
            cboPhongBan.DisplayMember = "NAME";
            cboPhongBan.ValueMember = "ID";
        }

        private void btnThem_Click(object sender, EventArgs e)
        {
            string id = txtId.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string role = cboRole.SelectedItem.ToString();
            string phone = txtPhone.Text.Trim();
            string fullName = txtFullName.Text.Trim();
            string departmentId = cboPhongBan.SelectedValue.ToString();

            string sql = "EXEC SP_INS_ENCRYPT_USER @ID, @EMAIL, @PASSWORD, @ROLE, @PHONE, @FULL_NAME, @DEPARTMENT_ID";
            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                {"@ID", id},
                {"@EMAIL", email},
                {"@PASSWORD", password},
                {"@ROLE", role},
                {"@PHONE", phone},
                {"@FULL_NAME", fullName},
                {"@DEPARTMENT_ID", departmentId}
            };

            Database.Execute(sql, parameters);
            load();
        }

        private void btnSua_Click(object sender, EventArgs e)
        {
            string id = txtId.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string role = cboRole.SelectedItem.ToString();
            string phone = txtPhone.Text.Trim();
            string fullName = txtFullName.Text.Trim();
            string departmentId = cboPhongBan.SelectedValue.ToString();

            string sql = "EXEC SP_UPD_ENCRYPT_USER @ID, @EMAIL, @PASSWORD, @ROLE, @PHONE, @FULL_NAME, @DEPARTMENT_ID";
            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                {"@ID", id},
                {"@EMAIL", email},
                {"@PASSWORD", password},
                {"@ROLE", role},
                {"@PHONE", phone},
                {"@FULL_NAME", fullName},
                {"@DEPARTMENT_ID", departmentId}
            };

            Database.Execute(sql, parameters);
            load();
        }

        private void btnXoa_Click(object sender, EventArgs e)
        {
            string id = txtId.Text.Trim();

            string sql = "EXEC SP_DEL_ENCRYPT_USER @ID";
            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                {"@ID", id}
            };

            Database.Execute(sql, parameters);
            load();
        }

        private void label7_Click(object sender, EventArgs e)
        {

        }

        private void label5_Click(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label6_Click(object sender, EventArgs e)
        {

        }
    }
}
