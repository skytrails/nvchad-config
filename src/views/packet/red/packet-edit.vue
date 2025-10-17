<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="edit-table"
    :title="isUpdate ? '修改红包' : '添加红包'"
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
      style="padding: 50px 100px"
    >
      <el-row :gutter="15">
        <el-col :sm="16">
          <el-form-item label="红包标题:" prop="title">
            <el-input
              clearable
              :maxlength="200"
              v-model="form.title"
              placeholder="请输入红包标题"
            />
          </el-form-item>
        </el-col>
        <el-col :sm="12">
          <el-form-item label="红包描述:">
            <el-input
              clearable
              :maxlength="50"
              v-model="form.description"
              placeholder="请输入描述"
            />
          </el-form-item>
          <el-form-item label="红包状态:" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :label="0">已停止</el-radio>
              <el-radio :label="1">生效中</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="红包类型:" prop="type">
            <el-radio-group v-model="form.type">
              <el-radio :label="0">随机红包</el-radio>
              <el-radio :label="1">固定红包</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
        <el-col :sm="16">
          <el-form-item label="关联基金:" prop="fundId">
            <el-select
              v-model="form.fundId"
              style="width: 100%"
              placeholder="请选择基金"
            >
              <el-option
                v-for="item in fundList"
                :key="'fund' + item.id"
                :label="item.name"
                :value="item.id"
              >
              </el-option>
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :sm="10">
          <el-form-item label="红包金额:" prop="amount">
            <el-input-number
              :disabled="isUpdate === true"
              :min="1000"
              :max="100000"
              :step="100"
              v-model="form.amount"
            ></el-input-number>
          </el-form-item>
        </el-col>
        <el-col :sm="10">
          <el-form-item label="红包数量:" prop="count">
            <el-input-number
              :disabled="isUpdate === true"
              :min="1"
              :max="10000"
              :step="50"
              v-model="form.count"
            ></el-input-number>
          </el-form-item>
        </el-col>
        <el-col :sm="16">
          <el-form-item label="生效时间:" prop="effectiveAt">
            <el-date-picker
              type="datetime"
              class="ele-fluid"
              v-model="form.effectiveAt"
              value-format="yyyy-MM-dd HH:mm:ss"
              placeholder="请选择生效时间"
            />
          </el-form-item>
        </el-col>
        <el-col :sm="16">
          <el-form-item label="过期时间:" prop="expiredAt">
            <el-date-picker
              type="datetime"
              class="ele-fluid"
              v-model="form.expiredAt"
              value-format="yyyy-MM-dd HH:mm:ss"
              placeholder="请选择过期时间"
            />
          </el-form-item>
        </el-col>
      </el-row>
      <el-form-item
        style="text-align: center; margin-left: -100px; margin-top: 10px"
      >
        <el-button @click="save" type="primary" size="medium">保存 </el-button>
        <el-button @click="$emit('close')" size="medium">返回</el-button>
      </el-form-item>
    </el-form>
  </el-drawer>
</template>

<script>
import "@riophae/vue-treeselect/dist/vue-treeselect.css";
import { mapGetters } from "vuex";
export default {
  name: "PacketEdit",
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array,
  },
  data() {
    return {
      showDrawer: this.visible,
      direction: "rtl",
      // 表单数据
      form: Object.assign({}, this.data),
      // 表单验证规则
      rules: {
        title: [{ required: true, message: "请输入红包标题", trigger: "blur" }],
        status: [
          { required: true, message: "请选择红包状态", trigger: "blur" },
        ],
        type: [
          { required: true, message: "请选择红包类型", trigger: "blur" },
        ],
        fundId: [
          { required: true, message: "请选择关联基金", trigger: "blur" },
        ],
        amount: [{ required: true, message: "请输入金额", trigger: "blur" }],
        count: [{ required: true, message: "请输入数量", trigger: "blur" }],
        effectiveAt: [{ required: true, message: "请输入生效时间", trigger: "blur" }],
        expiredAt: [{ required: true, message: "请输入过期时间", trigger: "blur" }],
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: "article",
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = {amount: 100, count: 50};
        this.isUpdate = false;
      }
    },
  },
  computed: {
    ...mapGetters(["fundList"]),
  },
  mounted() {
    this.getInfo();
  },
  methods: {
    /* 获取文章详情 */
    getInfo() {
      if (this.data.id > 0) {
        this.$http
          .get("/packet/info/" + this.data.id)
          .then((res) => {
            if (res.data.code === 200) {
              this.form = res.data.data;
              this.isUpdate = true;
            } else {
              this.$message.error(res.data.message);
            }
          })
          .catch((e) => {
            this.$message.error(e.message);
          });
      }
    },
    /* 保存编辑 */
    save() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.$http
            .post(this.isUpdate ? "/packet/update" : "/packet/create", this.form)
            .then((res) => {
              this.loading = false;
              if (res.data.code === 200) {
                this.$message.success(res.data.message);
                if (!this.isUpdate) {
                  this.form = {};
                }
                this.updateVisible(false);
                this.$emit("done");
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
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
      this.$emit("update:visible", value);
    },
    /* 关闭页面 */
    close(hide) {
      if (hide) {
        hide();
      }
      this.$emit("done");
    },
  },
};
</script>

<style scoped></style>
