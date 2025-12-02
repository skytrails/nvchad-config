<!-- 用户编辑弹窗 -->
<template>
  <el-dialog
    width="680px"
    :visible="visible"
    :lock-scroll="false"
    :destroy-on-close="true"
    custom-class="ele-dialog-form"
    :title="isUpdate?'修改用户':'添加用户'"
    @update:visible="updateVisible">
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="82px">
      <el-form-item label="头像：">
        <uploadImage :limit="1" :updDir="updDir" v-model="form.avatar"></uploadImage>
      </el-form-item>
      <el-row :gutter="15">
        <el-col :sm="12">
          <el-form-item label="登录账号:" prop="username">
            <el-input
              clearable
              :maxlength="20"
              :disabled="isUpdate"
              v-model="form.username"
              placeholder="请输入用户账号"/>
          </el-form-item>
          <el-form-item label="角色:" prop="roleIds">
            <el-select
              multiple
              clearable
              class="ele-block"
              v-model="form.roleIds"
              placeholder="请选择角色">
              <el-option
                v-for="item in roleList"
                :key="item.id"
                :value="item.id"
                :label="item.name"/>
            </el-select>
          </el-form-item>
          <el-form-item label="用户姓名:" prop="realname">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.realname"
              placeholder="请输入用户姓名"/>
          </el-form-item>
          <el-form-item label="邮箱:" prop="email">
            <el-input
              clearable
              :maxlength="100"
              v-model="form.email"
              placeholder="请输入邮箱"/>
          </el-form-item>
          <el-form-item label="状态:" prop="status">
            <el-radio-group
              v-model="form.status">
              <el-radio :label="1">在用</el-radio>
              <el-radio :label="2">禁用</el-radio>
            </el-radio-group>
          </el-form-item>

        </el-col>
        <el-col :sm="12">
          <el-form-item
            label="登录密码:"
            prop="password">
            <el-input
              show-password
              :maxlength="20"
              v-model="form.password"
              placeholder="请输入登录密码"/>
          </el-form-item>
          <el-form-item label="出生日期:" prop="birthday">
            <el-date-picker
              type="date"
              class="ele-fluid"
              v-model="form.birthday"
              value-format="yyyy-MM-dd"
              format="yyyy-MM-dd"
              placeholder="请选择出生日期"/>
          </el-form-item>
          <el-form-item label="性别:" prop="gender">
            <el-select
              clearable
              class="ele-block"
              v-model="form.gender"
              placeholder="请选择性别">
              <el-option label="男" :value="1"/>
              <el-option label="女" :value="2"/>
              <el-option label="保密" :value="3"/>
            </el-select>
          </el-form-item>
          <el-form-item label="手机号:" prop="mobile">
            <el-input
              clearable
              :maxlength="11"
              v-model="form.mobile"
              placeholder="请输入手机号"/>
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item label="个人简介:">
        <el-input
          :rows="3"
          clearable
          type="textarea"
          :maxlength="200"
          v-model="form.intro"
          placeholder="请输入个人简介"/>
      </el-form-item>
    </el-form>
    <div slot="footer">
      <el-button
        @click="updateVisible(false)">取消
      </el-button>
      <el-button
        type="primary"
        :loading="loading"
        @click="save">保存
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
import validate from 'ele-admin/packages/validate';
import uploadImage from '@/components/uploadImage'
// import Treeselect from '@riophae/vue-treeselect' // 下拉树
// import '@riophae/vue-treeselect/dist/vue-treeselect.css'
import regions from 'ele-admin/packages/regions';

export default {
  name: 'UserEdit',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object
  },
  components: {uploadImage},
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 选中的省市区
      city: [],
      // 选中的省市
      provinceCity: [],
      // 选中的省
      province: [],
      // 表单数据
      form: Object.assign({status: 1}, this.data),
      // 表单验证规则
      rules: {
        username: [
          {
            required: true,
            type: 'string',
            trigger: 'blur',
            // validator: (rule, value, callback) => {
            //   if (!value) {
            //     return callback(new Error('请输入用户账号'));
            //   }
            //   this.$http.get('/user/checkUser?username=' + value).then(res => {
            //     if (res.data.code !== 0 || !res.data.data.length) {
            //       return callback();
            //     }
            //     if (this.isUpdate && res.data.data[0].username === this.data.username) {
            //       return callback();
            //     }
            //     callback(new Error('账号已经存在'));
            //   }).catch(() => {
            //     callback();
            //   });
            // }
          }
        ],
        realname: [
          {required: false, message: '请输入用户姓名', trigger: 'blur'}
        ],
        gender: [
          {required: false, message: '请选择性别', trigger: 'blur'}
        ],
        birthday: [
          {required: false, message: '请选择出生日期', trigger: 'blur'}
        ],
        status: [
          {required: false, message: '请选择状态', trigger: 'blur'}
        ],
        roleIds: [
          {required: true, message: '请选择角色', trigger: 'blur'}
        ],
        email: [
          {pattern: validate.email, message: '邮箱格式不正确', trigger: 'blur'}
        ],
        mobile: [
          {pattern: validate.phone, message: '手机号格式不正确', trigger: 'blur'}
        ]
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: 'user',
      // 角色列表
      roleList: [],
      // 职级列表
      levelList: [],
      // 岗位列表
      positionList: [],
      // 部门列表
      deptList: [],
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data, {
          roleIds: this.data.roles.map(d => d.id)
        });
        // 取值赋予城市组件
        this.city = this.data.city;
        // 清空密码输入框
        this.form.password = ''
        this.isUpdate = true;
      } else {
        this.form = {};
        this.isUpdate = false;
        // 清空省市区控件
        this.city = [];
      }
    }
  },
  mounted() {
    this.queryRoles();  // 查询角色列表
  },
  methods: {
    /* 保存编辑 */
    save() {
      this.$refs['form'].validate((valid) => {
        if (valid) {
          this.loading = true;
          // 城市数据处理
          this.form = Object.assign({}, this.form, {
            city: this.city
          });
          this.$http.post(this.isUpdate ? '/sysUser/edit' : '/sysUser/add', this.form).then(res => {
            this.loading = false;
            if (res.data.code === 200) {
              this.$message({type: 'success', message: res.data.$message});
              if (!this.isUpdate) {
                this.form = {};
              }
              this.updateVisible(false);
              this.$emit('done');
            } else {
              this.$message.error(res.data.$message);
            }
          }).catch(e => {
            this.loading = false;
            this.$message.error(e.message);
          });
        } else {
          return false;
        }
      });
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit('update:visible', value);
    },
    /* 查询角色列表 */
    queryRoles() {
      this.$http.get('/role/getList').then(res => {
        if (res.data.code === 200) {
          this.roleList = res.data.data;
        } else {
          this.$message.error(res.data.$message);
        }
      }).catch(e => {
        this.$message.error(e.message);
      });
    },
  }
}
</script>

<style scoped>
</style>
