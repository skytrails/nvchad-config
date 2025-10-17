<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="edit-table"
    :title="isUpdate?'修改基金':'添加基金'"
    :visible.sync="showDrawer"
    :direction="direction"
    :size="'75%'"
    :before-close="close"
    >
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="90px"
      style="padding:50px 100px;">
      <!-- <el-form-item label="活动封面：">
        <uploadImage :limit="1" v-model="form.imageUrl"></uploadImage>
      </el-form-item> -->
      <el-row :gutter="15">
        <el-col :sm="16">
          <el-form-item label="基金名称:" prop="name">
            <el-input
              clearable
              :maxlength="200"
              v-model="form.name"
              placeholder="请输入基金名称"/>
          </el-form-item>
        </el-col>
        <el-col :sm="16">
          <el-form-item label="基金描述:" prop="description">
            <el-input
              type="textarea"
              :rows="3"
              v-model="form.description"
              placeholder="请输入活动简介"
              maxlength="200"
              show-word-limit />
          </el-form-item>
          <!-- <el-form-item label="基金状态:" prop="status">
            <el-radio-group
              v-model="form.status">
              <el-radio :label="1">生效中</el-radio>
              <el-radio :label="2">已停止</el-radio>
            </el-radio-group>
          </el-form-item> -->
        </el-col>
      </el-row>
      <el-form-item style="margin-top:10px;">
        <el-button @click="save" type="primary" size="medium">保存 </el-button>
        <el-button @click="$emit('close')" size="medium">返回</el-button>
      </el-form-item>
    </el-form>
  </el-drawer>
</template>

<script>

export default {
  name: 'FundEdit',
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array
  },
  data() {
    return {
      showDrawer: this.visible,
      direction: 'rtl',
      // 表单数据
      form: Object.assign({name: '', description: ''}, this.data),
      // 表单验证规则
      rules: {
        name: [
          {required: true, message: '请输入基金名称', trigger: 'blur'}
        ],
        status: [
          {required: true, message: '请选择基金状态', trigger: 'blur'}
        ],
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: 'article',
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = {};
        this.isUpdate = false;
      }
    }
  },
  computed: {
    formDateRange: {
      get() {
        return [this.form.startAt, this.form.endAt];
      },
      set(val) {
        this.form.startAt = val[0];
        this.form.endAt = val[1];
      }
    }
  },
  mounted() {
    this.getInfo();
  },
  methods: {
    /* 获取文章详情 */
    getInfo(){
      if (this.data.id > 0) {
        this.$http.get('/fundList/info/' + this.data.id).then(res => {
          if (res.data.code === 200) {
            this.form = res.data.data;
            this.isUpdate = true;
          } else {
            this.$message.error(res.data.message);
          }
        }).catch(e => {
          this.$message.error(e.message);
        });
      }
    },
    /* 保存编辑 */
    save() {
      this.$refs['form'].validate((valid) => {
        if (valid) {
          this.loading = true;
          if(this.form.id == null){
            delete this.form.id;
          }
          this.$http.post(this.isUpdate ? '/fundList/edit' : '/fundList/add', this.form).then(res => {
            this.loading = false;
            if (res.data.code === 200) {
              this.$message.success(res.data.message);
              if (!this.isUpdate) {
                this.form = {};
              }
              this.updateVisible(false);
              this.$emit('done');
            } else {
              this.$message.error(res.data.message);
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
    /* 关闭页面 */
    close(hide) {
      if (hide) {
        hide();
      }
      this.$emit("done");
    }
  }
}
</script>

<style scoped>
</style>
